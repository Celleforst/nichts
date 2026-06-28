{pkgs, ...}: {
  wayland.windowManager.hyprland.settings."exec-once" = [
    "systemctl --user start hyprpolkitagent"
    "${pkgs.dunst}/bin/dunst"
    "${pkgs.clipse}/bin/clipse -listen"
    "${pkgs.hyprpaper}/bin/hyprpaper"
    "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator"
    "${pkgs.blueman}/bin/blueman-applet"
    "${pkgs.hyprsunset}/bin/hyprsunset"
    "${pkgs.udiskie}/bin/udiskie --smart-tray"
  ];
}
