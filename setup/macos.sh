#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

echo "==> Installing macOS dependencies"

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is not installed. Install it first, then re-run this script." >&2
  exit 1
fi

brew update
brew install \
  git curl ripgrep ca-certificates gnupg unzip jq fontconfig \
  neovim bash-completion

mkdir -p "$HOME/repos" "$HOME/tools"
link_core_configs

echo
echo "Done. Your Bash, Neovim, and Doom configs are now linked from this repo."