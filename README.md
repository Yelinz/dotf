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

## Setup

Run the top-level setup script from the repo root:

- `./setup.sh` — detects Linux vs macOS and delegates to the right installer

For future refreshes after pulling repo changes:

- `./update.sh` — refresh the repo checkout if clean, then re-run the setup/link step

The platform installers do two things:

1. install the small set of baseline packages used by the configs
2. create safe symlinks from the standard config locations back into this repo

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
