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

apply_system_files() {
  local root src dest unit
  local nm_changed=0 systemd_changed=0 tmpfiles_changed=0
  root="$(repo_root)"
  [[ -d "$root/system" ]] || return 0

  echo "==> Applying system files from system/ (sudo)"
  while IFS= read -r -d '' src; do
    dest="${src#"$root/system"}"
    if sudo cmp -s "$src" "$dest"; then
      echo "[ok] $dest"
      continue
    fi
    sudo install -D -m "$(stat -c %a "$src")" "$src" "$dest"
    echo "[install] $dest"
    case "$dest" in
      /etc/NetworkManager/*) nm_changed=1 ;;
      /etc/systemd/*) systemd_changed=1 ;;
      /etc/tmpfiles.d/*) tmpfiles_changed=1 ;;
    esac
  done < <(find "$root/system" -type f -print0)

  if (( nm_changed )) && command -v nmcli >/dev/null 2>&1; then
    sudo nmcli general reload conf
    echo "[reload] NetworkManager configuration"
  fi

  if (( tmpfiles_changed )); then
    sudo systemd-tmpfiles --create
    echo "[apply] tmpfiles.d"
  fi

  if (( systemd_changed )); then
    sudo systemctl daemon-reload
    echo "[reload] systemd units (changed units are NOT restarted automatically)"
  fi

  # Every unit checked into system/etc/systemd/system is kept enabled.
  for src in "$root/system/etc/systemd/system"/*; do
    [[ -f "$src" ]] || continue
    unit="$(basename "$src")"
    if ! systemctl is-enabled --quiet "$unit" 2>/dev/null; then
      sudo systemctl enable "$unit"
      echo "[enable] $unit"
    fi
  done
}

apply_wake_on_lan() {
  # NetworkManager only pushes wake-on-lan to the NIC when a connection
  # (re)activates; set it with ethtool so it's live without bouncing the link.
  local dev
  while IFS= read -r dev; do
    if sudo ethtool -s "$dev" wol g 2>/dev/null; then
      echo "[wol] $dev: $(sudo ethtool "$dev" | grep -i 'wake-on: ' | tr -d '\t')"
    else
      echo "[warn] could not enable Wake-on-LAN on $dev" >&2
    fi
  done < <(nmcli -t -f DEVICE,TYPE,STATE device status 2>/dev/null |
    awk -F: '$2 == "ethernet" && $3 != "unmanaged" {print $1}')
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
}