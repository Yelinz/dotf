#!/usr/bin/env bash
# Self-contained HEVC NVENC batch transcoder for the RTX 2070 Super.
# Reads every video in INPUT_DIR, writes optimized .mkv to OUTPUT_DIR.
#
#   - Video : HEVC (h265) via NVENC, 10-bit, capped at 1080p
#   - Audio : keep Chinese (+Japanese) tracks only, re-encoded to Opus
#   - Subs  : keep ONE track, priority German > English > Chinese
#   - Skips files already done in OUTPUT_DIR (safe to re-run)
#
# Requires: an ffmpeg/ffprobe with NVENC support + NVIDIA driver on this machine.

set -euo pipefail

# ============================ EDIT THESE ====================================
INPUT_DIR="/mnt/homelab/Videos/Filme-Chinese-Input/"
OUTPUT_DIR="/run/media/yz/Oanh"
# ============================================================================
#
# ---- quality / encoder knobs (sane defaults) -------------------------------
CQ=24                 # 22 = better/bigger, 26 = smaller. 1080p HEVC sweet spot ~24
NVENC_PRESET="p7"     # p1 fastest .. p7 best quality (still fast on Turing)
MAX_HEIGHT=1080
MAXRATE="20M"
BUFSIZE="40M"
OPUS_KBPS=384         # enough for 5.1
AUDIO_LANGS="chi zho cmn yue chs cht"   # languages to KEEP (drop "jpn" for Chinese-only)
SUB_PRIORITY=("ger deu de" "eng en" "chi zho zh cmn yue chs cht")

FFMPEG="${FFMPEG:-ffmpeg}"
FFPROBE="${FFPROBE:-ffprobe}"

log() { printf '%s %s\n' "$(date '+%H:%M:%S')" "$*"; }

transcode_one() {
  local input="$1" real base stem output tmp
  real="$(readlink -f "$input")"
  base="$(basename "$input")"
  stem="${base%.*}"
  output="$OUTPUT_DIR/${stem}.mkv"
  tmp="$OUTPUT_DIR/.${stem}.partial.mkv"

  if [[ -f "$output" ]]; then log "[skip] $base"; return 0; fi
  log "[start] $base"

  # --- audio: keep wanted languages ---
  local -a amap=()
  while IFS=, read -r idx lang; do
    lang="${lang,,}"
    for w in $AUDIO_LANGS; do [[ "$lang" == "$w" ]] && { amap+=( -map "0:a:$idx" ); break; }; done
  done < <("$FFPROBE" -v error -select_streams a -show_entries stream_tags=language \
            -of csv=p=0 "$real" | awk -F, 'BEGIN{i=0}{print i++ "," $1}')
  [[ ${#amap[@]} -eq 0 ]] && { log "  [warn] no wanted audio; keeping first track"; amap=( -map "0:a:0?" ); }

  # --- subtitle: first match by priority, keep one ---
  local -a sstreams smap=(); local picked=""
  mapfile -t sstreams < <("$FFPROBE" -v error -select_streams s -show_entries stream_tags=language \
            -of csv=p=0 "$real" | awk -F, 'BEGIN{i=0}{print i++ "," $1}')
  for group in "${SUB_PRIORITY[@]}"; do
    for entry in "${sstreams[@]}"; do
      [[ -z "$entry" ]] && continue
      local sidx="${entry%%,*}" slang="${entry#*,}"; slang="${slang,,}"
      for w in $group; do [[ "$slang" == "$w" ]] && { smap=( -map "0:s:$sidx" ); picked="$w"; break 3; }; done
    done
  done
  [[ -n "$picked" ]] && log "  [sub] keeping $picked" || log "  [sub] none"
  local -a senc=(); [[ ${#smap[@]} -gt 0 ]] && senc=( -c:s copy )

  # --- encode: GPU decode + GPU scale + NVENC HEVC 10-bit (Turing-tuned) ---
  # aformat remaps non-standard layouts (e.g. DTS "5.1(side)") to ones Opus accepts.
  if ! "$FFMPEG" -hide_banner -y \
    -hwaccel cuda -hwaccel_output_format cuda \
    -i "$real" \
    -map 0:v:0 "${amap[@]}" ${smap[@]+"${smap[@]}"} \
    -vf "scale_cuda=-2:min(${MAX_HEIGHT}\,ih):format=p010le" \
    -c:v hevc_nvenc -preset "$NVENC_PRESET" -tune hq \
    -rc vbr -cq "$CQ" -b:v 0 -maxrate "$MAXRATE" -bufsize "$BUFSIZE" \
    -profile:v main10 -spatial_aq 1 -temporal_aq 1 -rc-lookahead 32 -b_ref_mode middle \
    -c:a libopus -vbr on -b:a "${OPUS_KBPS}k" -af "aformat=channel_layouts=7.1|5.1|stereo|mono" \
    ${senc[@]+"${senc[@]}"} \
    -map_metadata 0 -map_chapters 0 -tag:v hvc1 \
    "$tmp"; then
    log "  [error] ffmpeg failed: $base"
    rm -f "$tmp"
    return 1
  fi

  mv "$tmp" "$output"
  local src dst pct; src=$(stat -c%s "$real"); dst=$(stat -c%s "$output"); pct=$(( dst*100/src ))
  log "[done] $base  ${pct}% of source ($(numfmt --to=iec "$src") -> $(numfmt --to=iec "$dst"))"
}

# ---- main ------------------------------------------------------------------
[[ -d "$INPUT_DIR" ]]  || { echo "INPUT_DIR not found: $INPUT_DIR" >&2; exit 1; }
mkdir -p "$OUTPUT_DIR"

# Single-file mode: ./script.sh "/some/movie.mkv"
if [[ $# -ge 1 ]]; then transcode_one "$1"; exit 0; fi

shopt -s nullglob
declare -a files=()
for f in "$INPUT_DIR"/*; do
  [[ -f "$f" || -L "$f" ]] || continue
  case "${f,,}" in *.mkv|*.mp4|*.m4v|*.avi|*.mov|*.ts|*.wmv) files+=( "$f" );; esac
done

log "Found ${#files[@]} file(s) in $INPUT_DIR"
fail=0
for f in "${files[@]}"; do
  transcode_one "$f" || { log "[error] $(basename "$f")"; fail=$((fail+1)); }
done
log "Done. failures=$fail"
exit $(( fail > 0 ? 1 : 0 ))

