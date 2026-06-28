{...}: {
  wayland.windowManager.hyprland.settings.windowrule = [
    "tile 1, match:title ^(firefox)$"
    "float 1, match:title ^(pavucontrol)$"
    "float 1, match:title ^(blueman-manager)$"
    "float 1, match:title ^(nm-connection-editor)$"
    "float 1, match:title ^(galculator)$"
    "float 1, match:class clipse"
    "float 1, match:class blueberry.py"
    "float 1, pin 1, move 69.5% 4%, match:title ^(Picture-in-Picture)$"
    "size 622 652, match:class clipse"
    "stay_focused 1, match:class clipse"
  ];
}
