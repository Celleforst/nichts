_: {
  wayland.windowManager.hyprland.extraLuaFiles."decoration" = ''
    hl.config({
        decoration = {
            rounding = 4,
            active_opacity = 1.0,
            inactive_opacity = 0.9,
            blur = {
                enabled = true,
                size = 3,
                passes = 3,
                ignore_opacity = true,
            },
        },
    })
  '';
}
