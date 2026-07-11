#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

echo "==> Installing Arch Linux dependencies"

if command -v pacman >/dev/null 2>&1; then
  sudo pacman -S --needed --noconfirm \
    git curl ripgrep ca-certificates gnupg unzip jq fontconfig bash-completion \
    neovim gsimplecal
else
  echo "pacman not found; skipping package install" >&2
fi

mkdir -p "$HOME/repos" "$HOME/tools"
link_core_configs

echo
echo "Done. Your Bash, Neovim, and Doom configs are now linked from this repo."