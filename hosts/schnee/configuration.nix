{pkgs, ...}: {
  imports = [../../options/common/gpu/nvidia.nix];

  networking.hostId = "aefab460";
  networking.interfaces.enp7s0.useDHCP = true;
  systemd.services.zfs-mount.enable = true;
  nixpkgs.config.allowUnfree = true;
  networking.networkmanager.enable = true;
  environment.systemPackages = with pkgs; [networkmanager]; # cli tool for managing connections

  services.gnome.gnome-keyring.enable = true;
  # security.pam.services.sddm.enableGnomeKeyring = true;

  /*
    services.xserver.displayManager = {
    sddm.enable = true;
    sessionPackages = [  ];
  };
  */
  boot = {
    kernelParams = [];
    loader = {
      efi.efiSysMountPoint = "/boot";
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        extraEntries = ''
          menuentry "Reboot" {
            reboot
          }
          menuentry "Poweroff" {
            halt
          }
        '';
      };
    };
  };

  # virtualisation.virtualbox.host.enable = true;
  # programs.hyprland.xwayland.enable = true;
  # Enable Desktop Environment
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;
  security.polkit.enable = true;
  # services.xserver.displayManager.sessionPackages = [ pkgs.hyprland pkgs.sway ];

  # Important for gnome to recognise the monitors.xml that is written below
  # services.xserver.displayManager.gdm.wayland = true;

  # monitor config for gdm (wayland)

  # systemd.tmpfiles.rules = [
  #   "L+ /run/gdm/.config/monitors.xml - - - - ${pkgs.writeText "gdm-monitors.xml" (builtins.readFile ./monitors.xml)}"
  # ];

  #TODO: Add to  modules.system.monitors as option
  home-manager.users."dragyx".wayland.windowManager.hyprland.settings = {
    workspace = [
      "1,monitor:DP-2,default:true"
    ];
    exec-once = [
      "xrandr --output DP-2 --primary" # make sure xwayland windows open on right monitor:
    ];
  };

  modules = {
    login = {
      greetd.enable = true;
      session = "Hyprland";
    };
    system = rec {
      hostname = "schnee";
      username = "dragyx";
      gitPath = "/home/${username}/repos/nichts";
      bluetooth.enable = true;
      monitors = [
        {
          name = "Main";
          device = "DP-2";
          resolution = {
            x = 2560;
            y = 1440;
          };
          scale = 1.0;
          refresh_rate = 143.998001;
          position = {
            x = 0;
            y = 0;
          };
        }
        {
          name = "Right";
          device = "HDMI-A-3";
          resolution = {
            x = 2560;
            y = 1440;
          };
          scale = 1.0;
          refresh_rate = 74.9999001;
          position = {
            x = 2560;
            y = 200;
          };
          transform = 3;
        }
        {
          name = "Left";
          device = "HDMI-A-2";
          resolution = {
            x = 2560;
            y = 1440;
          };
          scale = 1.0;
          refresh_rate = 74.9999001;
          position = {
            x = -1440;
            y = 200;
          };
          transform = 1;
        }
      ];
      wayland = true;
      disks = {
        auto-partition.enable = true;
        swap-size = "64G";
        main-disk = "/dev/disk/by-id/nvme-Samsung_SSD_960_PRO_512GB_S3EWNX0K401532W";
        storage-disks = {
          "small" = "/dev/disk/by-id/nvme-eui.1847418009800001001b448b44810a1a";
          "medium" = "/dev/disk/by-id/wwn-0x50026b7783226e2f";
          "large" = "/dev/disk/by-id/wwn-0x5000c500bda8dba1";
        };
      };
    };
    other.home-manager = {
      enable = true;
      enableDirenv = true;
    };
    programs = {
      steam.enable = true;
      steam.gamescope = true;
      firefox.enable = true;
      vesktop.enable = false;
      btop.enable = true;
      mpv.enable = true;
      schizofox.enable = false;
      obs.enable = true;
      vivado.enable = false;
      rofi.enable = true;
      zathura.enable = true;
      i3.enable = false;
      git = {
        enable = true;
        userName = "Dragyx";
        userEmail = "66752602+Dragyx@users.noreply.github.com";
        defaultBranch = "main";
      };
      starship.enable = true;
      neovim-old.enable = true;
    };
    services = {
      pipewire.enable = true;
    };
    WM = {
      waybar.enable = true;
      hyprland = {
        enable = true;
        gnome-keyring.enable = true;
      };
    };
  };
  system.stateVersion = "21.11"; # Did you read the comment?
}
