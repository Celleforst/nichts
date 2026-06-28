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
  services.xserver = {
    enable = true;
displayManager.lightdm = {
      enable = true;
    };
    displayManager.autoLogin = {
      enable = true;
      user = "mk";
    };
    videoDrivers = [ "nvidia" ];
deviceSection = ''
      Option "ConnectedMonitor" "DP-5"
      Option "CustomEDID"
  "DP-5:/etc/X11/edid.bin"
      Option "UseEdid" "TRUE"
      Option
  "AllowEmptyInitialConfiguration" "yes"
    '';
};
services.displayManager.defaultSession ="none+openbox";
services.xserver.windowManager.openbox.enable = true;

  hardware.nvidia = {
    # Modesetting is required for most modern Wayland compositors (e.g., Hyprland, Sway).
    modesetting.enable = true;

    # Nvidia power management. Can cause issues with sleep/suspend on some systems.
    powerManagement.enable = false;
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not Nouveau).
    # Supported on Turing (RTX 20-series) and newer architectures.
    open = false;

    # Enable the Nvidia settings menu, accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Select the appropriate driver version (stable, beta, production, etc.)
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  hardware.nvidia-container-toolkit.enable = true;
  boot.blacklistedKernelModules = ["nouveau"];

  hardware.graphics = {
    enable = true;
  };

  nix.settings.substituters = [
    "https://cache.saumon.network/proxmox-nixos"
  ];
  nix.settings.trusted-public-keys = [
    "proxmox-nixos:D9RYSWpQQC/msZUWphOY2I5RLH5Dd6yQcaHIuug7dWM="
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "server-mk"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Needed for default bridge network to automatically work
  #boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  #boot.kernel.sysctl."net.ipv6.ip_forward" = 1;
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
};

environment.etc."X11/edid.bin".source = /home/mk/edid.bin;
 services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;  
    openFirewall = true;
  };
environment.systemPackages = [
    (pkgs.writeShellScriptBin "steam-bigpicture" ''
      export DISPLAY=:0
      export XAUTHORITY=/home/mk/.Xauthority
      exec ${pkgs.steam}/bin/steam steam://open/bigpicture
    '')
  ];
services.sunshine.package = pkgs.sunshine.override {
    cudaSupport = true;
    cudaPackages = pkgs.cudaPackages;
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
    extraGroups = ["libvirtd" "incus-admin" "wheel" "docker" "uinput"];
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
              config = {
                limits = {
                  cpu = 2;
                  memory = "4GiB";
                };
              };
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
            "--pull=always"
            "--restart=unless-stopped"
            "--rm=false"
          ];
        };
      };
      backend = "docker";
    };
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts = {
      "nextcloud.012204.xyz" = {
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
    url = "https://opencloud.012204.xyz";
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
  };

  services.cloudflared = {
    enable = true;
    tunnels = {
      "server-mk-tunnel" = {
        #    credentialsFile = "${config.sops.seorets.cloudflared-creds.path}";
        credentialsFile = "/var/lib/cloudflared/254305d4-c444-4bad-8c2b-efeab46b6799.json";
        default = "http_status:404";
        ingress = {
          "portainer.012204.xyz" = "http://localhost:9000";
          "homepage.012204.xyz" = "http://localhost:8082";
          "opencloud.012204.xyz" = "http://localhost:8081";
          "homeassistant.012204.xyz" = "http://192.168.1.161:8123";
          "server.012204.xyz" = "ssh://localhost:22";
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
