-- Desktop Waybar integration for Hyprland.
-- This file is required by the repo-managed hyprland.lua.
-- Migrated from conf.d/waybar-desktop.conf (hyprlang is deprecated since Hyprland 0.55).

-- Start Waybar once per session using the tracked desktop bar config.
hl.on("hyprland.start", function()
    hl.exec_cmd("waybar -b desktop -c ~/.config/waybar/config -s ~/.config/waybar/style.css")
end)

-- Optional blur rules for Waybar's layer namespace.
hl.layer_rule({
    name  = "waybar-blur",
    match = { namespace = "waybar" },

    blur         = true,
    ignore_alpha = 0.2,
    blur_popups  = true,
})
