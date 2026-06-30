{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  username = config.modules.system.username;
  cfg = config.modules.WM.waybar;
in {
  options.modules.WM.waybar.enable = lib.mkEnableOption "waybar";
  config = lib.mkIf cfg.enable {
    home-manager.users.${username} = {
      programs.waybar = {
        enable = true;
        systemd.enable = true;
        settings = {
          main = {
            height = 0;
            layer = "top";
            position = "top";
            modules-left = [
              "clock"
              "hyprland/workspaces"
              "custom/weather"
            ];
            modules-center = [
              "hyprland/window"
            ];
            modules-right = [
              "tray"
              "cpu"
              "memory"
              "network"
              "battery"
              "microphone"
              "backlight"
              "pulseaudio#speaker"
              "pulseaudio#microphone"
            ];

            #  Modules
            "custom/os-icon" = {
              format = ""; #NixOS logo
            };
            battery = {
              interval = 2;
              states = {
                good = 95;
                warning = 25;
                critical = 15;
              };
              format-time = "{H}:{M:02}";
              format = "{icon}";
              format-charging = " {capacity}%";
              format-charging-full = " {capacity}%";
              format-alt = "{icon} {capacity}%";
              format-full = "{icon}";
              format-icons = [
                ""
                ""
                ""
                ""
                ""
              ];
              tooltip = false;
            };
            clock = {
              interval = 10;
              format-alt = "  {:%d.%m.%Y}";
              tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
            };
            memory = {
              interval = 5;
              format = "󰍛  {}%";
              states = {
                warning = 70;
                critical = 90;
              };
              tooltip = false;
            };
            cpu = {
              interval = 5;
              format = "  {usage}%";
              tooltip = false;
              states = {
                warning = 70;
                critical = 90;
              };
            };
            network = {
              interval = 5;
              format-wifi = "{icon} {essid}";
              format-ethernet = "󰈁 {ifname}";
              format-disconnected = "2 Offline";
              format-alt = "󰇚 {bandwidthDownBytes} 󰕒 {bandwidthUpBytes} 󰩟 {ipaddr}/{cidr}";
              format-icons = [
                "󰤨 "
                "󰤥 "
                "󰤢 "
                "󰤟 "
                "󰤯 "
              ];
              tooltip = false;
            };
            "hyprland/mode" = {
              format = "test{}";
              tooltip = false;
            };
            "hyprland/window" = {
              format = "{initialTitle}";
              max-length = 30;
              tooltip = false;
            };
            "hyprland/workspaces" = {
              disable-scroll-wraparound = true;
              smooth-scrolling-threshold = 4;
              enable-bar-scroll = true;
              on-click = "activate";
              format = "{icon}";
              format-icons = {
                "1" = "Ⅰ";
                "2" = "Ⅱ";
                "3" = "Ⅲ";
                "4" = "Ⅳ";
                "5" = "Ⅴ";
                "6" = "Ⅵ";
                "7" = "Ⅶ";
                "8" = "Ⅷ";
                "9" = "Ⅸ";
                "10" = "Ⅹ";
                "11" = "Ⅺ";
                "12" = "Ⅻ";
              };
            };
            "pulseaudio#speaker" = {
              format = "{icon}  {volume}%";
              format-bluetooth = "{icon} {volume}%";
              format-muted = "󰸈 Muted";
              on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
              on-scroll-up = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%+";
              on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-";
              format-icons = {
                headphone = "";
                hands-free = "󱡏";
                headset = "󰋎";
                phone = "";
                portable = "";
                car = "";
                default = [
                  ""
                  ""
                  ""
                ];
              };
              scroll-step = 1;
              tooltip = false;
            };
            "pulseaudio#microphone" = {
              format = "{format_source}";
              format-source = "󰍬 {volume}%";
              format-source-muted = "󰍭 Muted";
              on-click = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
              on-scroll-up = "wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 1%-";
              on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 1%+";
              scroll-step = 1;
              tooltip = false;
            };
            temperature = {
              critical-threshold = 90;
              interval = 5;
              format = " {icon} {temperatureC}°";
              format-icons = [
                ""
                ""
                ""
                ""
                ""
              ];
              tooltip = false;
            };
            backlight = {
              format = "{icon}  {percent}%";
              on-click-middle = "brightnessctl set 100%";
              on-click-right = "brightnessctl set 1%";
              on-double-click = "brightnessctl set 50%";
              on-scroll-up = "brightnessctl set 1%+";
              on-scroll-down = "brightnessctl set 1%-";
              format-icons = [
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
              ];
              tooltip = false;
            };
            tray = {
              icon-size = 13;
              spacing = 10;
            };
            "custom/weather" = {
              tooltip = true;
              format = {};
              interval = 30;
              exec = "";
              return-type = "json";
            };
          };

          # Transparent overlay bar shown on top of fullscreen apps when battery is critical
          battery-warning = {
            layer = "overlay";
            position = "bottom";
            height = 30;
            passthrough = true;
            exclusive = false;
            modules-center = ["battery"];
            battery = {
              interval = 5;
              states.critical = 10;
              format = "";
              format-critical = "⚠  BATTERY CRITICAL — {capacity}%  ⚠";
              tooltip = false;
            };
          };
        };

        style = ''
          @keyframes blink {
              to { color: transparent; }
          }

          #battery.critical:not(.charging) {
              color: #ff4444;
              animation-name: blink;
              animation-duration: 0.75s;
              animation-timing-function: linear;
              animation-iteration-count: infinite;
              animation-direction: alternate;
          }

          /* overlay bar */
          window#waybar.bottom {
              background-color: transparent;
          }

          window#waybar.bottom #battery {
              background-color: transparent;
              color: transparent;
          }

          window#waybar.bottom #battery.critical {
              background-color: #cc0000;
              color: #ffffff;
              font-weight: bold;
              font-size: 13px;
              padding: 4px 20px;
              border-radius: 8px 8px 0 0;
          }
        '';
      };
    };
  };
}
