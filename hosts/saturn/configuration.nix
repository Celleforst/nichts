{
  lib,
  pkgs,
  ...
}: {
  # Time Zone
  time.timeZone = "Europe/Zurich";
  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  console.keyMap = "sg";
  security.polkit.enable = true;
  programs.kdeconnect.enable = true;
  programs.nix-ld.enable = false;
  # boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;
  services = {
    fstrim.enable = lib.mkDefault true;
    thermald.enable = true;
    auto-cpufreq.enable = true;
    printing.enable = true;
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };

  modules = {
    system = {
      impermanence.enable = false;
      hardware = {
        bluetooth = {
          enable = true;
          powerOnBoot = false;
        };
      };
      programs = {
        editors = {
          emacs.enable = false;
          neovim.enable = true;
          helix.enable = true;
        };
        discord.enable = true;
        # nushell.enable = true;
        eza.enable = false;
        firefox.enable = true;
        spotify.enable = true;
        # starship.enable = true;
        zellij.enable = true;
        terminals = {
          foot.enable = true;
        };
      };
      sound.enable = true;
    };
    usrEnv = {
      desktops.hyprland.enable = true;

      programs = {
        launchers = {
          fuzzel.enable = true;
        };

        media = {
          beets.enable = true;
          mpv.enable = true;
          ncmpcpp.enable = true;
        };
      };
      services = {
        locate.enable = true;
        greetd.enable = true;
      
        media.mpd = {
          enable = true;
        };
      };

      style = {
        gtk.enable = true;
        qt.enable = true;
      };
    };
    other = {
      system.username = "mk";
    };
    programs = {
      ssh.enable = true;
      btop.enable = true;
      nh.enable = true;
    };
  };
  system.stateVersion = "23.11";
}
