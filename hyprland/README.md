# Hyprland desktop setup (tracked in git)

This folder keeps your Waybar + Hyprland desktop customization in the repo and links it into `~/.config` via symlinks.

## What is included

- `hypr/hyprland.lua` — your tracked Hyprland main config (Lua; hyprlang is deprecated since Hyprland 0.55)
- `tools/hypr-window-swap.sh` — custom workspace/window swap helper (uses temporary workspace `999`)
- `waybar/config` — desktop-first Waybar layout and module config
- `waybar/style.css` — modern dark style with rounded module blocks
- `waybar/power_menu.xml` — GTK menu descriptor for power dropdown
- `hypr/waybar-desktop.lua` — Hyprland module for Waybar startup and layer blur rules
- `hypr/hyprland.conf`, `hypr/conf.d/waybar-desktop.conf` — legacy hyprlang configs, kept for reference (no longer linked)
- `install-links.sh` — symlink installer (safe backups for existing files)
- `install-fonts.sh` — installs Nerd Fonts needed for Waybar icons

## Setup

From the repo root:

1. Run the installer script:
   - `./hyprland/install-links.sh`
2. Install icon fonts (required for Waybar glyphs):
   - `./hyprland/install-fonts.sh`
3. Reload Hyprland:
   - `hyprctl reload`
   - Note: the config file is picked at startup, so switching between the legacy
     `.conf` and the Lua config requires a full Hyprland restart (log out/in),
     not just a reload.
4. Restart Waybar (if needed):
   - `pkill waybar && waybar -b desktop -c ~/.config/waybar/config -s ~/.config/waybar/style.css`

After linking, editing files in this repo updates your live config immediately (because the system paths are symlinks).

The installer also links `tools/hypr-window-swap.sh` to `~/tools/hypr-window-swap.sh` for your Hyprland keybind.

## Notes

- The bar is tuned for desktop usage (no battery/backlight modules).
- The rightmost module is a power dropdown with Suspend/Restart/Shutdown.
- Icons require Nerd Fonts (installed by `install-fonts.sh`).
- Clock uses `en_US.utf8` locale so it works on systems with the default installed locales.
- Clock hover shows a highlighted month calendar.
- Optional blur rules are included for Waybar's layer namespace.