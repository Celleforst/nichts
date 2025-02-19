{
  config,
  pkgs,
  ...
}: let
  cfg = config.modules.usrEnv.desktops.hyprland;
  inherit (builtins) map genList toString;
  in {
  programs.hyprland.settings = {
    # Keybinds
    bind =
      # workspaces
      # split-workspace is because of the split-workspace plugin
      # map (
      #  i: let
      #    mod = a: b: a - (b * (a / b));
      #    key = toString (mod i 10);
      #    workspace = toString i;
      #  in "$mainMod, ${key}, split:workspace, ${workspace}"
      # ) (genList (i: i + 1) 10)
      # # split-movetoworkspacesilent
      # ++ map (
      #  i: let
      #    mod = a: b: a - (b * (a / b));
      #    key = toString (mod i 10);
      #    workspace = toString i;
      #  in "$mainMod SHIFT, ${key}, split:movetoworkspacesilent, ${workspace}"
      # ) (genList (i: i + 1) 10)
      # ++ [
      [
        "$mainMod, RETURN, exec, foot"
        "$mainMod, C, killactive"
        "$mainMod, SPACE, fullscreen, 0"
        "$mainMod, M, exec, ${pkgs.procps}/bin/pkill walker || ${pkgs.walker}/bin/walker" # open App Menu
        "$mainMod, F, togglefloating, active"
        "$mainMod, S, togglesplit" # swap windows in split
        "$mainMod, Tab, workspace, m+1" # next workspace
        "$mainMod SHIFT, Tab, workspace, m-1" # previous workspace
        "$mainMod CTRL, Tab, workspace, empty" # next empty workspace

        # Screenshotting
        "$mainMod, S, exec, ${pkgs.grimblast}/bin/grimblast copy area" # only copy
        "$mainMod SHIFT, S, exec, ${pkgs.grimblast}/bin/grimblast save area - | ${pkgs.satty}/bin/satty -f -" # edit with satty

        # File manager
        "$mainMod, E, exec, ${pkgs.xfce.thunar}/bin/thunar"

        # Browser
        "$mainMod, B, exec, ${pkgs.firefox}/bin/firefox"

        # Toggle the three different special workspaces.
        "$mainMod, T, togglespecialworkspace, scratchpad"
        "$mainMod, N, togglespecialworkspace, nixos"
        "$mainMod, V, togglespecialworkspace, browser"

        # Reload hyprland
        "$mainMod, R, exec, ${cfg.package}/bin/hyprctl reload"

        # Restart waybar
        "$mainMod CONTROL, B, exec, ${pkgs.procps}/bin/pkill waybar || ${pkgs.waybar}/bin/waybar"
      ];

    binde = [
      # window focus
      "$mainMod, H, movefocus, l"
      "$mainMod, J, movefocus, d"
      "$mainMod, K, movefocus, u"
      "$mainMod, L, movefocus, r"

      # Move Windows
      "$mainMod SHIFT, H, movewindow, l"
      "$mainMod SHIFT, J, movewindow, d"
      "$mainMod SHIFT, K, movewindow, u"
      "$mainMod SHIFT, L, movewindow, r"

      # Move floating Windows
      "$mainMod CTRL, right, moveactive, 50 0"
      "$mainMod CTRL, left, moveactive, -50 0"
      "$mainMod CTRL, up, moveactive, 0 -50"
      "$mainMod CTRL, down, moveactive, 0 50"

      # Move Windows Group
      "$mainMod ALT, H, movewindoworgroup, l"
      "$mainMod ALT, J, movewindoworgroup, d"
      "$mainMod ALT, K, movewindoworgroup, u"
      "$mainMod ALT, L, movewindoworgroup, r"

      # Resize Windows
      "$mainMod CTRL, H, resizeactive, -50 0"
      "$mainMod CTRL, J, resizeactive, 50 0"
      "$mainMod CTRL, K, resizeactive, 0 -50"
      "$mainMod CTRL, L, resizeactive, 0 50"

       ];

    # Media controls
    bindl = let
      play-pause = "${pkgs.playerctl}/bin/playerctl play-pause";
      stop = "${pkgs.playerctl}/bin/playerctl stop";
      prev = "${pkgs.playerctl}/bin/playerctl previous";
      next = "${pkgs.playerctl}/bin/playerctl next";
      toggle-audio-mute = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
      toggle-mic-mute = "${pkgs.pavucontrol}/bin/pactl set-source-mute @DEFAULT_SOURCE@ toggle";
    in [
      ", XF86AudioMedia, exec, ${play-pause}"
      ", XF86AudioPlay,  exec, ${play-pause}"
      ", XF86AudioStop,  exec, ${stop}"
      ", XF86AudioPrev,  exec, ${prev}"
      ", XF86AudioNext,  exec, ${next}"
      ", XF86AudioMute,  exec, ${toggle-audio-mute}"
      ", XF86AudioMicMute,  exec, ${toggle-mic-mute}"
      ];
      

    # locked + repeat
    bindle = let
      volume_up = "${pkgs.wireplumber}/bin/wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+";
      volume_down = "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
      brightness_up = "${pkgs.brightnessctl}/bin/brightnessctl set +5%";
      brightness_down = "${pkgs.brightnessctl}/bin/brightnessctl set 5%-";
      brightness_100 = "${pkgs.brightnessctl}/bin/brightnessctl -q s 100%";
      brightness_1 = "${pkgs.brightnessctl}/bin/brightnessctl -q s 1%";
      brightness_50 = "${pkgs.brightnessctl}/bin/brightnessctl -q s 50%";
    in [
      ", XF86AudioRaiseVolume, exec, ${volume_up}"
      ", XF86AudioLowerVolume, exec, ${volume_down}"
      ", XF86MonBrightnessUp, exec, ${brightness_up}"
      ", XF86MonBrightnessDown, exec, ${brightness_down}"
      "SHIFT, XF86MonBrightnessUP, exec, ${brightness_50}"
      "SHIFT, XF86MonBrightnessDown, exec, ${brightness_1}"
      "$mainMod SHIFT, XF86MonBrightnessUP, exec, ${brightness_100}"
    ];

    # Mouse settings
    bindm = [
      "$mainMod, Control_L, movewindow"
      "$mainMod, ALT_L, resizewindow"
    ];

    # Some more movement-related settings
    binds = {
      pass_mouse_when_bound = false;
      movefocus_cycles_fullscreen = false;
    };
  };
}
