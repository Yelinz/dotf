# Dotfiles

Personal config, checked into one place with symlinks for the live files.

## What lives here

### Shell

- `shell/bashrc` — interactive Bash config
- `shell/profile` — login-shell environment setup
- `shell/bash_profile` — macOS-friendly Bash login entrypoint
- `shell/bash_aliases` — shell aliases and shortcuts

### Editors

- `nvim/init.lua` — Neovim configuration
- `nvim/lazy-lock.json` — pinned Neovim plugin versions
- `emacs/doom/init.el` — Doom module selection
- `emacs/doom/config.el` — Doom personal settings
- `emacs/doom/packages.el` — Doom package overrides
- `emacs/.doomrc` — Doom repo/runtime customization

### Desktop

- `hyprland/` — Hyprland + Waybar desktop profile

### System

- `system/` — files installed to the same path under `/` (e.g.
  `system/etc/NetworkManager/conf.d/50-wol.conf` → `/etc/NetworkManager/conf.d/50-wol.conf`).
  This is the Nix-flavored part of the repo: edit the file here, run `./setup.sh`,
  and the machine converges to what's checked in. Units under `etc/systemd/system/`
  are also enabled automatically. Currently:
  - `etc/NetworkManager/conf.d/50-wol.conf` — enable Wake-on-LAN (magic packet) on wired NICs
  - `etc/systemd/system/rclone-homelab.service` — mount homelab WebDAV at `/mnt/homelab`
  - `etc/systemd/system/rclone-proton-drive.service` — mount Proton Drive at `/mnt/protondrive`
  - `etc/tmpfiles.d/dotf.conf` — create the rclone mount points
  - `etc/modprobe.d/nvidia.conf` — nvidia DRM kernel modesetting
  - `etc/X11/xorg.conf.d/00-keyboard.conf` — keyboard layout (as written by localectl)

  The rclone units need remotes configured in `~/.config/rclone/rclone.conf`, which
  holds credentials and is deliberately **not** checked in.

## Setup

Run the top-level setup script from the repo root:

- `./setup.sh` — detects Linux vs macOS and delegates to the right installer

For future refreshes after pulling repo changes:

- `./update.sh` — refresh the repo checkout if clean, then re-run the setup/link step

The platform installers do three things:

1. install the small set of baseline packages used by the configs
2. create safe symlinks from the standard config locations back into this repo
3. (Linux) sync `system/` into `/` with sudo — only files whose content differs are
   reinstalled — then apply anything that needs a live kick (reload NetworkManager
   config, enable Wake-on-LAN on the NIC via ethtool)

### Symlinked paths

- `~/.bashrc`
- `~/.profile`
- `~/.bash_profile`
- `~/.bash_aliases`
- `~/.config/nvim/init.lua`
- `~/.config/nvim/lazy-lock.json`
- `~/.config/doom/init.el`
- `~/.config/doom/config.el`
- `~/.config/doom/packages.el`
- `~/.config/emacs/.doomrc`

If a live file already exists, the installer backs it up to `~/.config/dotf-backups/` first.

## Hyprland + Waybar

The desktop profile still lives in `hyprland/` and has its own installer:

- `hyprland/install-links.sh` — symlinks the Waybar/Hyprland config
- `hyprland/install-fonts.sh` — installs Nerd Fonts for the bar icons

See `hyprland/README.md` for the desktop-specific details.
