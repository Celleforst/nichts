{
  pkgs,
  lib,
  config,
  ...
}: {
  #services.vscode-server.enable = true;

  nixpkgs.config.permittedInsecurePackages = [
    "minio-2025-10-15T17-29-55Z"
  ];

  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 32 * 1024; # MB — set to your RAM size
    }
  ];

  systemd.services.docker = {
    after = ["network-online.target" "nss-lookup.target"];
    wants = ["nss-lookup.target"];
  };

  services.resolved.settings.Resolve.FallbackDNS = ["2620:fe::fe" "9.9.9.9"];

  systemd.network.wait-online.enable = true;

  systemd.services."cloudflared-tunnel-server-mk-tunnel" = {
    after = ["network-online.target" "nss-lookup.target"];
    wants = ["network-online.target" "nss-lookup.target"];
    serviceConfig = {
      # Tell systemd to wait 5 seconds between restart attempts
      # This prevents it from hitting the 5-try limit in under a second
      RestartSec = "5s";

      # Ensure it keeps trying on failure
      Restart = "on-failure";
    };
  };

  modules = {
    services.homepage.enable = true;
    system = rec {
      network.hostname = "server-mk";
      username = "mk";
      gitPath = "/home/mk/nichts";
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
  };

  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = ["/array"];
  };

  boot.initrd.kernelModules = ["nvidia" "i915" "nvidia_modeset" "nvidia_uvm" "nvidia_drm"];
  boot.kernelParams = ["video=HDMI-A-3:1920x1080@60"];
  # Always create HDMI PCM audio devices regardless of ELD/EDID validity,
  # so HDMI audio sinks appear in PipeWire even without a physical monitor.
  boot.extraModprobeConfig = ''
    options snd_hda_codec_hdmi static_hdmi_pcm=1
  '';

  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
    displayManager = {
      autoLogin = {
        enable = true;
        user = "mk";
      };
      sessionCommands = ''
        xset s off
        xset -dpms
        xset s noblank
        pkill -u mk steam || true
        ${pkgs.xorg.xrandr}/bin/xrandr --newmode "1920x1080" 148.50 1920 2008 2052 2200 1080 1084 1089 1125 +HSync +Vsync || true
        ${pkgs.xorg.xrandr}/bin/xrandr --addmode HDMI-0 "1920x1080" || true
        ${pkgs.xorg.xrandr}/bin/xrandr --output HDMI-0 --mode 1920x1080
        ${pkgs.feh}/bin/feh --bg-scale ${pkgs.catppuccin-wallpapers}/landscapes/salty_mountains.png
        ${pkgs.picom}/bin/picom --backend xrender --daemon
      '';
    };
    videoDrivers = ["nvidia"];

    deviceSection = ''
      Option "AllowEmptyInitialConfiguration"
      Option "ConnectedMonitor" "HDMI-0"
      Option "UseDisplayDevice" "HDMI-0"
      Option "ModeValidation" "NoMaxPClkCheck, NoEdidMaxPClkCheck, NoMaxSizeCheck, NoHorizSyncCheck, NoVertRefreshCheck, NoVirtualSizeCheck"
    '';

    screenSection = ''
      DefaultDepth 24
      SubSection "Display"
        Depth 24
        Virtual 1920 1080
      EndSubSection
    '';
  };

  security.wrappers.bwrap = {
    source = "${pkgs.bubblewrap}/bin/bwrap";
    setuid = true;
    owner = "root";
    group = "root";
  };

  services.displayManager.defaultSession = "none+openbox";
  services.xserver.windowManager.openbox.enable = true;

  hardware.nvidia = {
    # Modesetting is required for most modern Wayland compositors (e.g., Hyprland, Sway).
    modesetting.enable = true;

    # Nvidia power management. Can cause issues with sleep/suspend on some systems.
    powerManagement.enable = false;
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not Nouveau).
    # Supported on Turing (RTX 20-series) and newer architectures.
    open = true;

    # Enable the Nvidia settings menu, accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Select the appropriate driver version (stable, beta, production, etc.)
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  hardware.nvidia-container-toolkit.enable = true;
  boot.blacklistedKernelModules = ["nouveau"];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  programs.gamemode.enable = true;

  nix.settings.substituters = [
    "https://cache.saumon.network/proxmox-nixos"
    "https://cache.nixos.org https://cuda-maintainers.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "proxmox-nixos:D9RYSWpQQC/msZUWphOY2I5RLH5Dd6yQcaHIuug7dWM="
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "server-mk"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  networking = {
    networkmanager.enable = lib.mkForce false;
    useNetworkd = true;
    nftables.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [80 433];
      trustedInterfaces = ["docker0" "incusbr0"];
    };

    bridges.vmbr0 = {
      interfaces = ["eno1"];
    };
    interfaces.vmbr0 = {
      useDHCP = true;
    };
  };
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = false; # Open ports in the firewall for Steam Remote Play
    extraCompatPackages = [pkgs.proton-ge-bin];
  };

  # Oculus Rift CV1, via Monado (see pkgs/monado-cv1 for why it's a custom
  # build) as the system OpenXR runtime.
  services.monado = {
    enable = true;
    package = pkgs.monado-cv1;
    defaultRuntime = true;
    forceDefaultRuntime = true;
  };

  # Constellation (camera-based positional) tracking defaults off upstream;
  # confirmed working (both sensors streaming into the tracker) via manual
  # `RIFT_PROBER_CONSTELLATION_TRACKING=1 monado-cli probe` testing.
  systemd.user.services.monado.environment.RIFT_PROBER_CONSTELLATION_TRACKING = "1";

  services.udev.extraRules = ''
    # xr-hardware (pulled in automatically by services.monado) already covers
    # the CV1 HMD (2833:0031) and sensor (2833:0211), but this unit's sensor
    # also enumerates under 2833:2031, which isn't in that ruleset.
    ATTRS{idVendor}=="2833", ATTRS{idProduct}=="2031", TAG+="uaccess"
  '';

  #environment.etc."X11/edid.bin".source = /home/mk/edid.bin;
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
    settings.output_name = "HDMI-0";
  };

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "steam-bigpicture" ''
      export DISPLAY=:0
      export XAUTHORITY=/home/mk/.Xauthority
      pkill -u mk -x steam || true
      sleep 1
      exec ${pkgs.steam}/bin/steam -bigpicture
    '')
  ];
  services.sunshine.package = pkgs.sunshine.override {
    cudaSupport = true;
    inherit (pkgs) cudaPackages;
  };
  # Enables the uinput kernel module and creates the uinput group
  hardware.uinput.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      hinfo = true;
      userServices = true;
      workstation = true;
    };
    denyInterfaces = ["docker0"];
  };

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  users.users.mk = {
    extraGroups = ["libvirtd" "incus-admin" "wheel" "docker" "uinput" "video"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMYhGhiNq699nGBTiNYFLdL6RjlsxcUZiJadCFJfC8T8 mk@archlinux"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICRs6uWfeuOTpW6xuaHvxhoM44Lpfrn7ARRpu2maxkQq u0_a121@localhost"
    ];
  };
  users.extraGroups.docker.members = ["mk"];
  services.getty.autologinUser = "mk";
  services.fstrim.enable = true;
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    settings.X11Forwarding = true;
  };
  security.sudo.extraConfig = ''
    Defaults env_keep+= "DISPALY XAUTHORITY SSH_AUTH_SOCK"
  '';

  programs.ssh.setXAuthLocation = true;

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
  };

  systemd.services.docker-alt = {
    description = "Docker Daemon (alternate)";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "notify";
      ExecStart = pkgs.writeShellScript "docker-alt-start" ''
        exec ${pkgs.docker}/bin/dockerd \
          --host unix:///run/docker-alt.sock \
          --data-root /array/docker-root \
          --exec-root /run/docker-alt \
          --pidfile /run/docker-alt.pid
      '';
      ExecReload = "${pkgs.coreutils}/bin/kill -s HUP $MAINPID";
      Restart = "on-failure";
      TimeoutSec = 0;
    };
  };

  virtualisation = {
    libvirtd = {
      enable = true;
      # Used for UEFI boot of Home Assistant OS guest image
      qemu = {
        package = pkgs.qemu_kvm;
      };
    };

    incus = {
      enable = true;
      ui.enable = true; # Enable web UI
      preseed = {
        networks = [
          {
            name = "incusbr0";
            type = "bridge";
            config = {
              "ipv4.address" = "10.0.100.1/24";
              "ipv4.nat" = "true";
            };
          }
        ];
        storage_pools = [
          {
            name = "default";
            driver = "dir";
            config = {
              source = "/var/lib/storage_pools/default";
            };
          }
        ];
        profiles = [
          {
            name = "default";
            devices = {
              eth0 = {
                name = "eth0";
                network = "incusbr0";
                type = "nic";
              };
              root = {
                path = "/";
                pool = "default";
                type = "disk";
                size = "35GiB";
              };
            };
          }
          {
            name = "vm";
            devices = {
              eth0 = {
                name = "eth0";
                network = "incusbr0";
                type = "nic";
              };
              root = {
                path = "/";
                pool = "default";
                type = "disk";
              };
            };
            config = {
              "limits.cpu" = "2";
              "limits.memory" = "4GiB";
            };
          }
        ];
      };
    };

    docker = {
      enable = true;
      daemon.settings = {
        "data-root" = "/var/lib/docker";
        storage-driver = "btrfs";
        dns = ["9.9.9.9" "1.1.1.1"];
      };
      rootless = {
        enable = false;
        setSocketVariable = false;
        daemon.settings = {
          "data-root" = "/var/lib/docker-rootless";
          dns = ["8.8.8.8" "1.1.1.1"];
          storage-driver = "btrfs";
        };
      };
    };
    oci-containers = {
      containers = {
        portainer-ce = {
          image = "portainer/portainer-ce:latest";
          volumes = [
            "portainer_data:/data"
            "/var/run/docker.sock:/var/run/docker.sock"
            "/etc/localtime:/etc/localtime"
          ];
          ports = [
            "9443:9443"
            "9000:9000" # HTTP
          ];
          autoStart = true;
          extraOptions = [
            "--pull=missing"
          ];
        };
      };
      backend = "docker";
    };
  };

  nichts.build-host.enable = true;

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts = {
      "nextcloud.002204.xyz" = {
        listen = [
          {
            addr = "127.0.0.1";
            port = 8080;
          }
        ];
      };
      "server-mk" = {
        locations = {
          "/" = {
            proxyPass = "http://localhost:8090/";
            proxyWebsockets = true;
            #proxyPass = "http://192.168.1.160:11000/";
          };
        };
      };
    };
  };

  sops.secrets.opencloud-admin-pass = {};

  sops.templates."opencloud.env" = {
    content = ''
      IDM_ADMIN_PASSWORD=${config.sops.placeholder.opencloud-admin-pass}
    '';
  };

  services.opencloud = {
    enable = true;
    url = "https://opencloud.002204.xyz";
    environment = {
      PROXY_TLS = "false";
      OC_INSECURE = "true";
    };
    stateDir = "/data/opencloud";
    port = 8081;
    environmentFile = config.sops.templates."opencloud.env".path;
  };

  boot.kernel.sysctl = {
    "net.core.rmem_max" = 7340032;
    "net.core.wmem_max" = 7340032;
    # Prevent ephemeral ports from colliding with Sunshine's fixed ports (RTSP 48010, video/audio 47984-48010)
    "net.ipv4.ip_local_reserved_ports" = "47984-48010";
  };

  services.cloudflared = {
    enable = true;
    tunnels = {
      "server-mk-tunnel" = {
        #    credentialsFile = "${config.sops.seorets.cloudflared-creds.path}";
        credentialsFile = "/var/lib/cloudflared/254305d4-c444-4bad-8c2b-efeab46b6799.json";
        default = "http_status:404";
        warp-routing.enabled = true;
        ingress = {
          "portainer.002204.xyz" = "http://localhost:9000";
          "homepage.002204.xyz" = "http://localhost:8082";
          "opencloud.002204.xyz" = "http://localhost:8081";
          "homeassistant.002204.xyz" = "http://192.168.1.161:8123";
          "server.002204.xyz" = "ssh://localhost:22";
        };
      };
    };
  };
  programs.ssh.startAgent = true;

  services.btrbk = {
    instances.main = {
      onCalendar = "weekly";
      settings = {
        snapshot_preserve_min = "4w";
        snapshot_preserve = "4w";
        target_preserve_min = "4w";
        target_preserve = "4w";

        volume = {
          "/mnt/btrfs-root" = {
            subvolume = {
              "@" = {
                snapshot_dir = "@snapshots";
                target = "/array/backups/root";
              };
              "@home" = {
                snapshot_dir = "@snapshots";
                target = "/array/backups/home";
              };
            };
          };
          "/mnt/btrfs-var" = {
            subvolume = {
              "@log" = {
                snapshot_dir = "@snapshots-var";
                target = "/array/backups/log";
              };
              "@db" = {
                snapshot_dir = "@snapshots-var";
                target = "/array/backups/db";
              };
            };
          };
        };
      };
    };
  };

  system.stateVersion = "25.05"; # Did you read the comment?
}
