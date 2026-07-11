#!/usr/bin/env bash
set -euo pipefail

repo_root() {
  cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd
}

backup_root() {
  printf '%s/dotf-backups' "${XDG_CONFIG_HOME:-$HOME/.config}"
}

timestamp() {
  date +%Y%m%d-%H%M%S
}

link_path() {
  local source_path="$1"
  local target_path="$2"
  local target_dir current_target desired_target backup_path

  target_dir="$(dirname "$target_path")"
  mkdir -p "$target_dir"

  if [[ -L "$target_path" ]]; then
    current_target="$(readlink -f "$target_path")"
    desired_target="$(readlink -f "$source_path")"
    if [[ "$current_target" == "$desired_target" ]]; then
      echo "[ok] Already linked: $target_path -> $source_path"
      return 0
    fi
  fi

  if [[ -e "$target_path" || -L "$target_path" ]]; then
    backup_path="$(backup_root)/$(basename "$target_path").$(timestamp)"
    mkdir -p "$(backup_root)"
    mv "$target_path" "$backup_path"
    echo "[backup] $target_path -> $backup_path"
  fi

  ln -s "$source_path" "$target_path"
  echo "[link] $target_path -> $source_path"
}

link_core_configs() {
  local root
  root="$(repo_root)"

  link_path "$root/shell/bashrc" "$HOME/.bashrc"
  link_path "$root/shell/bash_profile" "$HOME/.bash_profile"
  link_path "$root/shell/profile" "$HOME/.profile"
  link_path "$root/shell/bash_aliases" "$HOME/.bash_aliases"

  link_path "$root/nvim/init.lua" "$HOME/.config/nvim/init.lua"
  link_path "$root/nvim/lazy-lock.json" "$HOME/.config/nvim/lazy-lock.json"

  link_path "$root/emacs/doom/init.el" "$HOME/.config/doom/init.el"
  link_path "$root/emacs/doom/config.el" "$HOME/.config/doom/config.el"
  link_path "$root/emacs/doom/packages.el" "$HOME/.config/doom/packages.el"
  link_path "$root/emacs/.doomrc" "$HOME/.config/emacs/.doomrc"
}