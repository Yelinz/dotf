#!/usr/bin/env bash
set -euo pipefail

INTERVAL="${1:-10}"
SAMPLES="${2:-0}"   # 0 = run forever
MAX_LINES="${MAX_LINES:-20}"

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

is_pos_int() {
  [[ "$1" =~ ^[0-9]+$ ]]
}

if ! is_pos_int "$INTERVAL" || [[ "$INTERVAL" -lt 1 ]]; then
  echo "INTERVAL must be an integer >= 1" >&2
  exit 1
fi

if ! is_pos_int "$SAMPLES"; then
  echo "SAMPLES must be an integer >= 0 (0 means infinite)" >&2
  exit 1
fi

print_divider() {
  printf '\n%s\n' "================================================================================"
}

print_snapshot() {
  print_divider
  echo "time: $(date '+%F %T %Z')"
  echo "loadavg: $(cut -d' ' -f1-3 /proc/loadavg)"

  if [[ -r /proc/pressure/io ]]; then
    echo
    echo "[io pressure] (/proc/pressure/io)"
    cat /proc/pressure/io
  fi

  if [[ -r /proc/pressure/cpu ]]; then
    echo
    echo "[cpu pressure] (/proc/pressure/cpu)"
    cat /proc/pressure/cpu
  fi

  if [[ -r /proc/pressure/memory ]]; then
    echo
    echo "[memory pressure] (/proc/pressure/memory)"
    cat /proc/pressure/memory
  fi

  echo
  echo "[service state]"
  if has_cmd systemctl; then
    for svc in jellyfin; do
      if systemctl is-active --quiet "$svc"; then
        echo "$svc: active"
      else
        echo "$svc: inactive/failed"
      fi
    done
  else
    echo "systemctl not available"
  fi

  if has_cmd docker; then
    echo
    echo "[target containers]"
    docker ps --format '{{.Names}}\t{{.Status}}' | grep -E '^(deluge|immich_server|immich_machine_learning|copyparty)\b' || true

    echo
    echo "[container block I/O snapshot]"
    echo -e "NAME\tCPU\tMEM\tBLOCK I/O"
    docker stats --no-stream --format '{{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.BlockIO}}' \
      | grep -E '^(deluge|immich_server|immich_machine_learning|copyparty)\b|^' \
      | head -n "$MAX_LINES"
  else
    echo
    echo "docker not available"
  fi

  echo
  echo "[top cgroups by I/O]"
  if has_cmd systemd-cgtop; then
    systemd-cgtop -b -n 1 --depth=2 2>/dev/null | sed -n "1,${MAX_LINES}p"
  else
    echo "systemd-cgtop not available"
  fi

  echo
  if has_cmd iostat; then
    echo "[disk util/latency via iostat]"
    iostat -dx 1 2
  else
    echo "[disk counters fallback]"
    echo "iostat not installed; install sysstat for await/%util."
    awk '
      $3 ~ /^(sd|nvme|vd|md|dm-)/ {
        printf("%s\treads_completed=%s\twrites_completed=%s\tsectors_read=%s\tsectors_written=%s\tio_time_ms=%s\n",
          $3, $4, $8, $6, $10, $13)
      }
    ' /proc/diskstats
  fi

  echo
  echo "Hint: io pressure sustained some.avg10 > 5 or full.avg10 > 1 usually means noticeable slowdown on HDDs."
}

count=0
while true; do
  print_snapshot
  count=$((count + 1))

  if [[ "$SAMPLES" -gt 0 && "$count" -ge "$SAMPLES" ]]; then
    break
  fi

  sleep "$INTERVAL"
done
