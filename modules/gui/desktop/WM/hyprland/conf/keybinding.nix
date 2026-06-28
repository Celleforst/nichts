{pkgs, ...}: let
  terminal = "${pkgs.alacritty}/bin/alacritty";
  files = "${pkgs.nemo}/bin/nemo";
  browser = "${pkgs.firefox}/bin/firefox";
  launcher = "rofi -show drun -show-icons";
  lock = "${pkgs.hyprlock}/bin/hyprlock";
  screenshot = "${pkgs.grimblast}/bin/grimblast";
  satty = "${pkgs.satty}/bin/satty";
  playerctl = "${pkgs.playerctl}/bin/playerctl";
  wpctl = "${pkgs.wireplumber}/bin/wpctl";
  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
in {
  wayland.windowManager.hyprland.settings = {
    bind = [
      # Applications
      "$mainMod, Return, exec, ${terminal}"
      "$mainMod, B, exec, ${browser}"
      "$mainMod, E, exec, ${files}"
      "$mainMod, M, exec, ${launcher}"
      "$mainMod CTRL, B, exec, ${pkgs.alacritty}/bin/alacritty -e ${pkgs.bluetuith}/bin/bluetuith"
      "$mainMod CTRL, N, exec, nm-connection-editor"

      # Windows
      "$mainMod, C, killactive"
      "$mainMod, Space, fullscreen"
      "$mainMod, F, togglefloating"
      "$mainMod, S, layoutmsg, togglesplit"

      # Window focus
      "$mainMod, h, movefocus, l"
      "$mainMod, l, movefocus, r"
      "$mainMod, k, movefocus, u"
      "$mainMod, j, movefocus, d"

      # Window move
      "$mainMod SHIFT, h, movewindow, l"
      "$mainMod SHIFT, l, movewindow, r"
      "$mainMod SHIFT, k, movewindow, u"
      "$mainMod SHIFT, j, movewindow, d"
      "$mainMod ALT, right, moveactive, 200 0"
      "$mainMod ALT, left, moveactive, -200 0"
      "$mainMod ALT, up, moveactive, 0 -200"
      "$mainMod ALT, down, moveactive, 0 200"
      "$mainMod ALT, h, movewindoworgroup, l"
      "$mainMod ALT, l, movewindoworgroup, r"
      "$mainMod ALT, k, movewindoworgroup, u"
      "$mainMod ALT, j, movewindoworgroup, d"

      # Window resize
      "$mainMod CTRL, h, resizeactive, -50 0"
      "$mainMod CTRL, l, resizeactive, 50 0"
      "$mainMod CTRL, k, resizeactive, 0 -50"
      "$mainMod CTRL, j, resizeactive, 0 50"

      # Groups
      "$mainMod, G, togglegroup"
      "$mainMod SHIFT, G, changegroupactive"

      # Scratchpad
      "$mainMod, apostrophe, togglespecialworkspace"
      "$mainMod SHIFT, apostrophe, movetoworkspace, special"

      # Actions
      ", PRINT, exec, ${screenshot} copy area"
      "$mainMod SHIFT, S, exec, ${screenshot} save area - | ${satty} -f -"
      "CTRL ALT, L, exec, ${lock}"
      "$mainMod, L, exec, ${lock}"
      "$mainMod, V, exec, ${pkgs.clipse}/bin/clipse"
      "$mainMod CTRL, R, exec, pkill waybar || waybar"
      "$mainMod SHIFT, R, exec, hyprctl reload"

      # Workspaces
      "$mainMod, 1, workspace, 1"
      "$mainMod, 2, workspace, 2"
      "$mainMod, 3, workspace, 3"
      "$mainMod, 4, workspace, 4"
      "$mainMod, 5, workspace, 5"
      "$mainMod, 6, workspace, 6"
      "$mainMod, 7, workspace, 7"
      "$mainMod, 8, workspace, 8"
      "$mainMod, 9, workspace, 9"
      "$mainMod, 0, workspace, 10"
      "$mainMod SHIFT, 1, movetoworkspace, 1"
      "$mainMod SHIFT, 2, movetoworkspace, 2"
      "$mainMod SHIFT, 3, movetoworkspace, 3"
      "$mainMod SHIFT, 4, movetoworkspace, 4"
      "$mainMod SHIFT, 5, movetoworkspace, 5"
      "$mainMod SHIFT, 6, movetoworkspace, 6"
      "$mainMod SHIFT, 7, movetoworkspace, 7"
      "$mainMod SHIFT, 8, movetoworkspace, 8"
      "$mainMod SHIFT, 9, movetoworkspace, 9"
      "$mainMod SHIFT, 0, movetoworkspace, 10"
      "$mainMod, Tab, workspace, m+1"
      "$mainMod SHIFT, Tab, workspace, m-1"
      "$mainMod CTRL, Tab, workspace, empty"

      # Fn keys
      ", XF86MonBrightnessUp, exec, ${brightnessctl} -q s +5%"
      ", XF86MonBrightnessDown, exec, ${brightnessctl} -q s 5%-"
      "SHIFT, XF86MonBrightnessUP, exec, ${brightnessctl} -q s 50%"
      "$mainMod SHIFT, XF86MonBrightnessUP, exec, ${brightnessctl} -q s 100%"
      "SHIFT, XF86MonBrightnessDown, exec, ${brightnessctl} -q s 1%"
      ", XF86AudioMute, exec, ${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ", XF86AudioMicMute, exec, ${wpctl} set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
      ", XF86AudioPlay, exec, ${playerctl} play-pause"
      ", XF86AudioPause, exec, ${playerctl} pause"
      ", XF86AudioNext, exec, ${playerctl} next"
      ", XF86AudioPrev, exec, ${playerctl} previous"
      ", XF86Lock, exec, ${lock}"
    ];

    binde = [
      ", XF86AudioRaiseVolume, exec, ${wpctl} set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"
      ", XF86AudioLowerVolume, exec, ${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%-"
    ];

    bindl = [
      ", switch:Lid Switch, exec, ${lock}"
    ];

    bindm = [
      "$mainMod SHIFT, Control_L, movewindow"
      "$mainMod, ALT_L, resizewindow"
    ];

  };

  # Submaps need ordered placement in the config file
  wayland.windowManager.hyprland.extraConfig = ''
    bind = $mainMod CTRL, P, submap, passthru
    submap = passthru
    bind = $mainMod CTRL, Backspace, submap, reset
    submap = reset
  '';
}
