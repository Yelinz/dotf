#!/usr/bin/env bash
set -euo pipefail

FONT_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/fonts"
TMP_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

download() {
  local url="$1"
  local out="$2"

  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$url" -o "$out"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "$out" "$url"
  else
    echo "Need curl or wget to download fonts." >&2
    exit 1
  fi
}

need_cmd unzip
need_cmd fc-cache

mkdir -p "$FONT_DIR"

echo "[fonts] Downloading JetBrainsMono Nerd Font..."
download "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" "$TMP_DIR/JetBrainsMono.zip"

echo "[fonts] Downloading Symbols Nerd Font..."
download "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/NerdFontsSymbolsOnly.zip" "$TMP_DIR/NerdFontsSymbolsOnly.zip"

echo "[fonts] Installing into $FONT_DIR"
unzip -o "$TMP_DIR/JetBrainsMono.zip" -d "$FONT_DIR" >/dev/null
unzip -o "$TMP_DIR/NerdFontsSymbolsOnly.zip" -d "$FONT_DIR" >/dev/null

echo "[fonts] Rebuilding font cache"
fc-cache -f "$FONT_DIR"

echo "Done. Nerd Fonts installed for Waybar icons."
