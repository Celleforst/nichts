_: {
  wayland.windowManager.hyprland.extraLuaFiles."layout" = ''
    hl.config({
        dwindle = {
            preserve_split = true,
        },
        binds = {
            workspace_back_and_forth = true,
            allow_workspace_cycles = true,
            pass_mouse_when_bound = false,
        },
    })

    hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
    hl.gesture({ fingers = 4, direction = "down",       action = "close" })
    hl.gesture({ fingers = 3, direction = "vertical",   mods = "SUPER", action = "resize" })
  '';
}
