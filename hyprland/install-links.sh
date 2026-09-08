#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
TOOLS_HOME="$HOME/tools"
BACKUP_DIR="${CONFIG_HOME}/dotf-backups"
STAMP="$(date +%Y%m%d-%H%M%S)"

mkdir -p "$BACKUP_DIR"

link_path() {
    local source_path="$1"
    local target_path="$2"
    local target_dir

    target_dir="$(dirname "$target_path")"
    mkdir -p "$target_dir"

    if [[ -L "$target_path" ]]; then
        local current_target
        local desired_target
        current_target="$(readlink -f "$target_path")"
        desired_target="$(readlink -f "$source_path")"

        if [[ "$current_target" == "$desired_target" ]]; then
            echo "[ok] Already linked: $target_path -> $source_path"
            return
        fi
    fi

    if [[ -e "$target_path" || -L "$target_path" ]]; then
        local backup_path
        backup_path="${BACKUP_DIR}/$(basename "$target_path").${STAMP}"
        mv "$target_path" "$backup_path"
        echo "[backup] $target_path -> $backup_path"
    fi

    ln -s "$source_path" "$target_path"
    echo "[link] $target_path -> $source_path"
}

link_path "$REPO_DIR/waybar" "$CONFIG_HOME/waybar"
link_path "$REPO_DIR/hypr/hyprland.lua" "$CONFIG_HOME/hypr/hyprland.lua"
link_path "$REPO_DIR/hypr/waybar-desktop.lua" "$CONFIG_HOME/hypr/waybar-desktop.lua"

chmod +x "$REPO_DIR/tools/hypr-window-swap.sh"
link_path "$REPO_DIR/tools/hypr-window-swap.sh" "$TOOLS_HOME/hypr-window-swap.sh"

echo
echo "Done. Edits in this repo now propagate to your live config via symlinks."
echo "Hyprland and Waybar are now linked from this repo."
echo "Custom tools are linked to: $TOOLS_HOME"
echo "Reload Hyprland with: hyprctl reload"