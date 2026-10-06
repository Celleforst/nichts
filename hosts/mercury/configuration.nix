_: {
  # Secure Boot is mandatorily enabled in firmware here with no Setup/BIOS
  # password available. The boot bypass + later shim+MOK signing steps are
  # covered in docs/mercury-install.md, not in this file -- none of it is a
  # NixOS config concern, it all happens before/outside nixos-install.

  networking.networkmanager.enable = true;
  home-manager.users.mk.home.stateVersion = "26.11";

  modules = {
    system = {
      network.hostname = "mercury";
      username = "mk";
      gitPath = "/home/mk/nichts";
      secureboot = {
        enable = true;
        certFile = ../../keys/secureboot.cer;
      };
      disks = {
        auto-partition.enable = true;
        encrypt-root.enable = true;
        # Replace with the real by-id path before running disko. Find it with:
        #   ls -la /dev/disk/by-id/
        main-disk = "/dev/disk/by-id/CHANGE_ME";
        # Adjust to the target machine's RAM size.
        swap-size = "8G";
      };
    };
  };

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    age.keyFile = "/home/mk/.config/sops/age/keys.txt";
  };

  # Intentionally no WM/GUI modules yet -- get this booting and confirmed
  # stable first (see docs/mercury-install.md), then layer a desktop on.

  system.stateVersion = "26.11";
}
