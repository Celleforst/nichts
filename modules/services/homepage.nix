{
  config,
  lib,
  ...
}: let
  cfg = config.modules.services.homepage;
in {
  options.modules.services.homepage.enable = lib.mkEnableOption "homepage-dashboard";

  config = lib.mkIf cfg.enable {
    services.homepage-dashboard = {
      enable = true;
      listenPort = 8082;
      openFirewall = false;

      settings = {
        title = "server-mk";
        theme = "dark";
        color = "slate";
        headerStyle = "clean";
        cardBlur = "sm";
        layout = {
          Infrastructure = {
            style = "row";
            columns = 3;
          };
          Cloud = {
            style = "row";
            columns = 2;
          };
          "Smart Home" = {
            style = "row";
            columns = 2;
          };
        };
      };

      widgets = [
        {
          resources = {
            cpu = true;
            memory = true;
            disk = ["/"];
            label = "server-mk";
          };
        }
        {
          datetime = {
            text_size = "xl";
            format = {
              dateStyle = "short";
              timeStyle = "short";
              hourCycle = "h23";
            };
          };
        }
        {
          search = {
            provider = "duckduckgo";
            target = "_blank";
          };
        }
      ];

      services = [
        {
          Infrastructure = [
            {
              Portainer = {
                icon = "portainer.svg";
                href = "https://portainer.012204.xyz";
                description = "Container Management";
                widget = {
                  type = "portainer";
                  url = "http://localhost:9000";
                  # Generate in Portainer: Settings → Users → Access Tokens
                  # key = "...";
                  env = 2;
                };
              };
            }
            {
              Incus = {
                icon = "si-linuxcontainers";
                href = "https://server-mk:8443";
                description = "VM & Container Management";
              };
            }
            {
              Sunshine = {
                icon = "sunshine.png";
                href = "https://server-mk:47990";
                description = "Game Streaming";
                widget = {
                  type = "sunshine";
                  url = "https://server-mk:47990";
                  # username = "admin";
                  # password = "...";
                };
              };
            }
          ];
        }
        {
          Cloud = [
            {
              OpenCloud = {
                icon = "nextcloud.svg";
                href = "https://opencloud.012204.xyz";
                description = "File Storage & Collaboration";
              };
            }
          ];
        }
        {
          "Smart Home" = [
            {
              "Home Assistant" = {
                icon = "home-assistant.svg";
                href = "https://homeassistant.012204.xyz";
                description = "Home Automation";
                widget = {
                  type = "homeassistant";
                  url = "http://192.168.1.161:8123";
                  # Long-lived access token from HA profile → Security
                  # key = "...";
                };
              };
            }
          ];
        }
      ];

      bookmarks = [
        {
          "Quick Links" = [
            {"NixOS Packages" = [{href = "https://search.nixos.org/packages";}];}
            {"NixOS Options" = [{href = "https://search.nixos.org/options";}];}
            {"Home Manager Options" = [{href = "https://home-manager-options.extendrealmsstudio.com";}];}
            {"GitHub" = [{href = "https://github.com";}];}
          ];
        }
      ];
    };
  };
}
