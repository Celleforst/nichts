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
      sessionPackages = [pkgs.hyprland];
      defaultSession = "hyprland";
    };

    environment.systemPackages = with pkgs; [
      xwayland
      hyprshade
      hyprlock
      hyprpaper
      hyprsunset
      rofi
      waybar
      lxqt.lxqt-openssh-askpass
      libdrm
      dunst
      alacritty
      nemo
      pciutils
      grimblast
      satty
      clipse
      udiskie
      networkmanagerapplet
      blueman
      playerctl
      wireplumber
    ];

    programs.xwayland.enable = true;
    programs.hyprland = {
      enable = true;
      withUWSM = true;
    };

    services.gnome.gnome-keyring.enable = cfg.gnome-keyring.enable;
    security.pam.services.login.enableGnomeKeyring = cfg.gnome-keyring.enable;

    services.displayManager.sddm.wayland.enable = true;

    home-manager.users.${username} = {
      imports = [
        ./hyprland/conf/autostart.nix
        ./hyprland/conf/cursor.nix
        ./hyprland/conf/keyboard.nix
        ./hyprland/conf/window.nix
        ./hyprland/conf/decoration.nix
        ./hyprland/conf/layout.nix
        ./hyprland/conf/misc.nix
        ./hyprland/conf/keybinding.nix
        ./hyprland/conf/windowrule.nix
        ./hyprland/conf/animation.nix
        ./hyprland/conf/env.nix
      ];

      home.packages = with pkgs; [
        bluetuith
        brightnessctl
        wl-clipboard
        bibata-cursors
      ];

      xdg.desktopEntries.hyprlock = {
        name = "Hyprlock";
        exec = "${getExe pkgs.hyprlock}";
      };

      services.hypridle = {
        enable = true;
        settings = {
          general = {
            lock_cmd = "${getExe pkgs.hyprlock}";
            before_sleep_cmd = "loginctl lock-session";
            after_sleep_cmd = "hyprctl dispatch dpms on";
            ignore_dbus_inhibit = false;
            ignore_systemd_inhibit = false;
          };
          listener = [
            {
              timeout = 30;
              on-timeout = "pidof hyprlock && hyprctl dispatch dpms off && ${pkgs.brightnessctl}/bin/brightnessctl -sd tpacpi::kbd_backlight set 0";
              on-resume = "pidof hyprlock && hyprctl dispatch dpms on && ${pkgs.brightnessctl}/bin/brightnessctl -rd tpacpi::kbd_backlight";
            }
            {
              timeout = 150;
              on-timeout = "${pkgs.brightnessctl}/bin/brightnessctl -s set 10";
              on-resume = "${pkgs.brightnessctl}/bin/brightnessctl -r";
            }
            {
              timeout = 150;
              on-timeout = "${pkgs.brightnessctl}/bin/brightnessctl -sd tpacpi::kbd_backlight set 0";
              on-resume = "${pkgs.brightnessctl}/bin/brightnessctl -rd tpacpi::kbd_backlight";
            }
            {
              timeout = 300;
              on-timeout = "loginctl lock-session";
            }
            {
              timeout = 330;
              on-timeout = "hyprctl dispatch dpms off";
              on-resume = "hyprctl dispatch dpms on";
            }
            {
              timeout = 1000;
              on-timeout = "systemctl suspend";
            }
          ];
        };
      };

      wayland.windowManager.hyprland = {
        enable = true;
        configType = "hyprlang";
        systemd.enable = true;
        xwayland.enable = true;
        settings = {
          "$mainMod" = "SUPER";
          monitor = map (
            m: "${m.device},${toString m.resolution.x}x${toString m.resolution.y}@${toString m.refresh_rate},${toString m.position.x}x${toString m.position.y},${toString m.scale}"
          ) monitors;
        };
      };
    };
  };
}
