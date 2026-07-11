#!/usr/bin/env bash
set -euo pipefail

# Collect active workspace IDs per monitor.
mapfile -t WS < <(
  hyprctl monitors -j | jq -r '.[].activeWorkspace.id'
)

# Require exactly two monitors.
[ "${#WS[@]}" -eq 2 ] || exit 0

wsA="${WS[0]}"
wsB="${WS[1]}"

# Nothing to do if both monitors show same workspace.
[ "$wsA" != "$wsB" ] || exit 0

tmp="special:swap_tmp"

move_all() {
  local from="$1"
  local to="$2"

  hyprctl clients -j |
    jq -r --arg from "$from" ".[] | select((.workspace.id | tostring) == \$from or .workspace.name == \$from) | .address" |
    while read -r addr; do
      hyprctl dispatch movetoworkspacesilent "$to,address:$addr" || true
    done
}

# Swap all windows.
move_all "$wsA" "$tmp"
move_all "$wsB" "$wsA"
move_all "$tmp" "$wsB"
