_: {
  wayland.windowManager.hyprland.extraLuaFiles."cursor" = ''
    hl.config({
        cursor = {
            no_hardware_cursors = true,
        },
    })
  '';
}
