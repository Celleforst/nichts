{pkgs, ...}: {
  wayland.windowManager.hyprland.extraLuaFiles."autostart" = ''
    hl.on("hyprland.start", function()
        hl.exec_cmd("systemctl --user start hyprpolkitagent")
        hl.exec_cmd("${pkgs.dunst}/bin/dunst")
        hl.exec_cmd("sh -c '${pkgs.clipse}/bin/clipse -listen < /dev/null'")
        hl.exec_cmd("${pkgs.hyprpaper}/bin/hyprpaper")
        hl.exec_cmd("${pkgs.networkmanagerapplet}/bin/nm-applet --indicator")
        hl.exec_cmd("${pkgs.blueman}/bin/blueman-applet")
        hl.exec_cmd("${pkgs.hyprsunset}/bin/hyprsunset")
        hl.exec_cmd("${pkgs.udiskie}/bin/udiskie --smart-tray")
    end)
  '';
}
