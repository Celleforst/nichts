_: {
  wayland.windowManager.hyprland.extraLuaFiles."general" = ''
    hl.config({
        general = {
            gaps_in  = 5,
            gaps_out = 5,
            border_size = 1,
            col = {
                active_border   = { colors = { "rgba(ffe1ccee)", "rgba(c89aeaaa)" }, angle = 45 },
                inactive_border = "rgba(595959aa)",
            },
            layout = "dwindle",
            resize_on_border = true,
        },
    })
  '';
}
