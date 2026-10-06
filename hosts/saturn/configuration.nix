{
  pkgs,
  lib,
  ...
}: {
  networking.networkmanager.enable = true;
  networking.networkmanager.plugins = [pkgs.networkmanager-openconnect];
  environment.systemPackages = with pkgs; [networkmanager openconnect]; # cli tool for managing connections
  home-manager.users.mk.home.stateVersion = "25.11";
  services = {
    pipewire.enable = true;
  };

  environment.sessionVariables = {
    NIXPKGS_ALLOW_UNFREE = "1";
  };

  services.gnome.gnome-keyring.enable = true;

  nichts.remote-builders.enable = true;

  users.users.mk.extraGroups = ["dialout" "plugdev"];
  networking.modemmanager.enable = false;
  systemd.services.NetworkManager-wait-online.enable = false;

  boot = {
    binfmt.emulatedSystems = ["aarch64-linux"];
    binfmt.registrations.aarch64-linux.fixBinary = true;
    kernelParams = [];
    loader = {
      efi.efiSysMountPoint = "/boot";
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        useOSProber = true;
        extraEntries = ''
          menuentry "System Rescue" {
            insmod part_gpt
            insmod fat
            search --no-floppy --set=root --label SYSRESCUE
            linux /sysresccd/boot/x86_64/vmlinuz archisobasedir=sysresccd archisolabel=SYSRESCUE copytoram
            initrd /sysresccd/boot/x86_64/sysresccd.img
          }
        '';
      };
    };
  };
  security.polkit.enable = true;
  security.polkit.enablePkexecWrapper = true;
  programs.kdeconnect.enable = true;
  programs.nix-ld.enable = true;

  services.forticlient.enable = true;
  # libgbm.so.1 is built by pkgs.libgbm (pname "mesa-libgbm") in this nixpkgs,
  # not by the `mesa` package the module's baseLibraries already covers.
  services.forticlient.extraLibraries = with pkgs; [libgbm];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true; # optional, replaces ssh-agent
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="05c6", ATTRS{idProduct}=="9008", MODE="0666", GROUP="plugdev"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="05c6", ATTRS{idProduct}=="900e", MODE="0666", GROUP="plugdev"
    ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="608c", MODE="0664", GROUP="plugdev", TAG+="uaccess"
  '';

  services.cloudflare-warp.enable = true;

  modules.services.fingerprint.enable = true;

  hardware.graphics = {
    enable = true;
    extraPackages = [pkgs.intel-media-driver]; # Broadwell (5th gen) and newer
  };

  console.keyMap = "sg";
  modules = {
    login = {
      greetd.enable = true;
      session = "uwsm start -- hyprland.desktop";
    };
    system = rec {
      intel.enable = true;
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
    services.docker.enable = true;
    programs = {
      #firefox.enable = true;
      alacritty = {
        enable = true;
        blur = true;
        fake_term = true;
      };
      vscode.enable = true;
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
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    age.keyFile = "/home/mk/.config/sops/age/keys.txt";
  };

  virtualisation.vmVariant = {
    home-manager.users.mk.wayland.windowManager.hyprland.extraConfig = lib.mkForce ''
      hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
    '';
    virtualisation.cores = 4;
    virtualisation.memorySize = 4096;
  };

  system.stateVersion = "26.11"; # Did you read the comment?
}
