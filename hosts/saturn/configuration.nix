{pkgs, ...}: {
  networking.networkmanager.enable = true;
  environment.systemPackages = with pkgs; [networkmanager]; # cli tool for managing connections
    home-manager.users.mk.home.stateVersion = "25.11";
    services = {
      pipewire.enable = true;
    };

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

programs.gnupg.agent = {
  enable = true;
  enableSSHSupport = true;  # optional, replaces ssh-agent
};

  home-manager.users."mk".wayland.windowManager.hyprland.settings = {
    workspace = [
      "1,monitor:eDP-1,default:true"
    ];
  };

  console.keyMap = "sg";
  modules = {
    login = {
      greetd.enable = true;
      session = "uwsm start -- hyprland.desktop";
    };
    system = rec {
      network.hostname = "saturn";
      username = "mk";
      gitPath = "/home/mk/nichts";
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
      #firefox.enable = true;
      vesktop.enable = true;
      btop.enable = true;
      mpv.enable = true;
      obs.enable = true;
      rofi.enable = true;
      zathura.enable = true;
      starship.enable = true;
      neovim-old.enable = true;
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
