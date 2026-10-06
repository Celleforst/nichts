_: {
  wayland.windowManager.hyprland.extraLuaFiles."misc" = ''
    hl.config({
        misc = {
            disable_hyprland_logo   = true,
            disable_splash_rendering = true,
            mouse_move_enables_dpms = true,
            swallow_regex = "^(Alacritty)$",
        },
    })
  '';
}
