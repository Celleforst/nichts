{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.WM.hyprland;
  username = config.modules.system.username;
  monitors = config.modules.system.monitors;
  inherit (lib) mkEnableOption mkIf getExe;
in {
  options.modules.WM.hyprland = {
    enable = mkEnableOption "hyprland";
    gnome-keyring.enable = mkEnableOption "gnome-keyring";
  };

  config = mkIf cfg.enable {
    services.displayManager = {
      sessionPackages = [pkgs.hyprland]; # pkgs.gnome.gnome-session.sessions ];
      defaultSession = "hyprland";
    };

    environment.systemPackages = with pkgs; [
      xwayland
      swww
      hyprshade
      hyprlock
      rofi-wayland
      waybar
      lxqt.lxqt-openssh-askpass
      libdrm
      dunst
      pciutils # lspci is needed by hyprland
      grimblast
      satty
    ];

    programs.xwayland.enable = true;
    programs.hyprland.enable = true;

    services.gnome.gnome-keyring.enable = cfg.gnome-keyring.enable;
    security.pam.services.login.enableGnomeKeyring = cfg.gnome-keyring.enable;

    services.displayManager.sddm.wayland.enable = true;
    systemd.user.services.polkit-gnome-authentication-agent-1 = mkIf cfg.gnome-keyring.enable {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = ["graphical-session.target"];
      wants = ["graphical-session.target"];
      after = ["graphical-session.target"];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };

    home-manager.users.${username} = {
      home.packages = with pkgs; [
        bluetuith
        brightnessctl
        # needed for wayland copy / paste support in neovim
        wl-clipboard
      ];

      xdg.desktopEntries.hyprlock = {
        name = "Hyprlock";
        exec = "${getExe pkgs.hyprlock}";
      };

      services.hypridle = {
        enable = true;
        settings.before_sleep_cmd = "${getExe pkgs.hyprlock}";
      };

      wayland.windowManager.hyprland = {
        enable = true;
        systemd.enable = true;
        xwayland.enable = true;
        settings = {
          "$mainMod" = "SUPER"; 
          exec-once =
            (
              if cfg.gnome-keyring.enable
              then ["${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"]
              else []
            );
            # ++ [
            #   "${pkgs.swww}/bin/swww-daemon"
            #   "${getExe pkgs.nextcloud-client}"
            # ];
            
          monitor =
            map (
              m: "${m.device},${toString m.resolution.x}x${toString m.resolution.y}@${toString m.refresh_rate},${toString m.position.x}x${toString m.position.y},${toString m.scale},transform,${toString m.transform}"
            )
            monitors; #TODO: default value

          input = {
            kb_layout = "ch,de,us";
            kb_variant = ",,";
            kb_options = "grp:rctrl_rshift_toggle, caps:escape";
            accel_profile = "flat";
            force_no_accel = true;

            repeat_rate = 50;
            repeat_delay = 200;

            follow_mouse = true;
            sensitivity = 0.4;
            
            touchpad = {
              disable_while_typing = true;
              natural_scroll = true;
              };
          };

          general = {
            gaps_in = 5;
            gaps_out = 5;
            border_size = 1;
            "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
            "col.inactive_border" = "rgba(595959aa)";
            layout = "dwindle";
          };

          cursor.no_hardware_cursors = true;
          decoration.rounding = 5;
          misc.disable_hyprland_logo = true;
          animations = {
            enabled = false;
            # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

            bezier = ["myBezier, 0.05, 0.9, 0.1, 1.05"];

            animation = [
              "windowsOut, 1, 7, default, popin 80%"
              "border, 1, 10, default"
              "borderangle, 1, 8, default"
              "fade, 1, 7, default"
              "workspaces, 1, 6, default"
              "windows, 1, 7, myBezier"
            ];
          };

          xwayland = {
            force_zero_scaling = true;
          };

          gestures.workspace_swipe = true;
          debug.enable_stdout_logs = true;
          debug.disable_logs = true;
          windowrulev2 = [
            "float,title:bluetuith"
            "float,title:nmtui"
          ];

          bind = [
            "$mainMod, RETURN, exec, footclient"
            "$mainMod, C, killactive"
            "$mainMod, SPACE, fullscreen, 0"
            # "$mainMod, M, exec, ${pkgs.procps}/bin/pkill walker || ${pkgs.walker}/bin/walker" # open App Menu
            "$mainMod, M, exec, rofi -show drun -show-icons"
            "$mainMod, F, togglefloating, active"
            "$mainMod, S, togglesplit" # swap windows in split
            "$mainMod, Tab, workspace, m+1" # next workspace
            "$mainMod SHIFT, Tab, workspace, m-1" # previous workspace
            "$mainMod CTRL, Tab, workspace, empty" # next empty workspace
            # "SUPER, B, exec, footclient --title=bluetuith ${pkgs.bluetuith}/bin/bluetuith"
            # "SUPER, N, exec, footclient --title=nmtui ${pkgs.networkmanager}/bin/nmtui"

            # Screenshotting
            # ",PRINT, exec, ${getExe pkgs.satty} -f \"$(${getExe pkgs.grimblast} copysave area $(mktemp --suffix .png))\" -o ~/Pictures/Screenshots/screenshot-annotated-$(date -Iminutes).png"
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
            # "$mainMod, R, exec, ${cfg.package}/bin/hyprctl reload"

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

            # move to next / previous workspace"
            "SUPER CTRL, j, workspace, r-1"
            "SUPER CTRL, k, workspace, r+1"

            # move window to next / previous workspace"
            "SUPER CTRL, h, movetoworkspace, r-1"
            "SUPER CTRL, l, movetoworkspace, r+1"
            ];

          # Media controls
          bindl = let
            play-pause = "${pkgs.playerctl}/bin/playerctl play-pause";
            stop = "${pkgs.playerctl}/bin/playerctl stop";
            prev = "${pkgs.playerctl}/bin/playerctl previous";
            next = "${pkgs.playerctl}/bin/playerctl next";
            toggle-audio-mute = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            toggle-mic-mute = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            brightness_100 = "${pkgs.brightnessctl}/bin/brightnessctl -q s 100%";
            brightness_1 = "${pkgs.brightnessctl}/bin/brightnessctl -q s 1%";
            brightness_50 = "${pkgs.brightnessctl}/bin/brightnessctl -q s 50%";
          in [
            ", XF86AudioMedia, exec, ${play-pause}"
            ", XF86AudioPlay,  exec, ${play-pause}"
            ", XF86AudioStop,  exec, ${stop}"
            ", XF86AudioPrev,  exec, ${prev}"
            ", XF86AudioNext,  exec, ${next}"
            ", XF86AudioMute,  exec, ${toggle-audio-mute}"
            ", XF86AudioMicMute,  exec, ${toggle-mic-mute}"
            "SHIFT, XF86MonBrightnessUP, exec, ${brightness_50}"
            "SHIFT, XF86MonBrightnessDown, exec, ${brightness_1}"
            "$mainMod SHIFT, XF86MonBrightnessUP, exec, ${brightness_100}"
            ];
      

          # locked + repeat
          bindle = let
            volume_up = "${pkgs.wireplumber}/bin/wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+";
            volume_down = "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
            brightness_up = "${pkgs.brightnessctl}/bin/brightnessctl set +5%";
            brightness_down = "${pkgs.brightnessctl}/bin/brightnessctl set 5%-";
          in [
            ", XF86AudioRaiseVolume, exec, ${volume_up}"
            ", XF86AudioLowerVolume, exec, ${volume_down}"
            ", XF86MonBrightnessUp, exec, ${brightness_up}"
            ", XF86MonBrightnessDown, exec, ${brightness_down}"
          ];

          # Mouse settings
          bindm = [
            "$mainMod SHIFT, Control_L, movewindow"
            "$mainMod SHIFT, ALT_L, resizewindow"
          ];

          # Some more movement-related settings
          binds = {
            pass_mouse_when_bound = false;
            movefocus_cycles_fullscreen = false;
          };
          env = [
            "XCURSOR_SIZE,24"
          ];
        };
      };
    };
  };
}
