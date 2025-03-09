{pkgs, ...}: {
  networking.networkmanager.enable = true;
  environment.systemPackages = with pkgs; [networkmanager]; # cli tool for managing connections

  services.gnome.gnome-keyring.enable = true;

  boot = {
    kernelParams = [];
    loader = {
      efi.efiSysMountPoint = "/boot";
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
      };
    };
  };
  security.polkit.enable = true;

  home-manager.users."mk".wayland.windowManager.hyprland.settings = {
    workspace = [
      "1,monitor:eDP-1,default:true"
    ];
  };

  console.keyMap = "sg";
  modules = {
    login = {
      greetd.enable = true;
      session = "Hyprland";
    };
    system = rec {
      network.hostname = "saturn";
      username = "mk";
      gitPath = "/flake/nichts";
      monitors = [
        {
          name = "Main";
          device = "eDP-1";
          resolution = {
            x = 1920;
            y = 1080;
          };
          scale = 1;
          refresh_rate = 60.05600;
          position = {
            x = 0;
            y = 0;
          };
        }
        ];
      wayland = true;
      disks = {
        auto-partition.enable = false;
        swap-size = "64G";
        main-disk = "/dev/disk/by-id/nvme-KINGSTON_SNV2S250G_50026B7686A07983_1";
      };
    };
    other.home-manager = {
      enable = true;
      enableDirenv = true;
    };
    programs = {
      firefox.enable = true;
      vesktop.enable = true;
      btop.enable = true;
      mpv.enable = true;
      obs.enable = true;
      rofi.enable = true;
      zathura.enable = true;
      git = {
        enable = true;
        userName = "Marcello Krahforst";
        userEmail = "77944684+Celleforst@users.noreply.github.com";
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
  system.stateVersion = "24.11"; # Did you read the comment?
}
