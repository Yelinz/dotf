# Dotfiles

Personal config.

## Hyprland + Waybar (desktop profile)

This repo now includes a desktop-focused Waybar setup and a Hyprland snippet in `hyprland/`.

- `hyprland/hypr/hyprland.conf` — tracked Hyprland main config
- `hyprland/tools/hypr-window-swap.sh` — vendored custom workspace swap helper script
- `hyprland/waybar/config.jsonc` — Waybar module layout (desktop-first, no laptop battery/backlight modules)
- `hyprland/waybar/style.css` — modern dark aesthetic (Catppuccin-inspired)
- `hyprland/waybar/power_menu.xml` — power dropdown menu descriptor
- `hyprland/hypr/conf.d/waybar-desktop.conf` — Hyprland include for launching Waybar + blur layer rules
- `hyprland/install-links.sh` — creates symlinks from `~/.config` to this repo so edits here immediately propagate to your system
- `hyprland/install-fonts.sh` — installs Nerd Fonts needed for Waybar icons

See `hyprland/README.md` for install and usage instructions.
