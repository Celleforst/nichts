{
  config = {
    #boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-uuid/d51ce0fa-8c62-4b38-b6b8-1671f7088c59";
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/a9ba61a6-85c8-40a1-93be-31a15ab3d32c";
      fsType = "btrfs";
      options = [ "subvol=@" "compress=zstd" "noatime" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/a9ba61a6-85c8-40a1-93be-31a15ab3d32c";
      fsType = "btrfs";
      options = [ "subvol=@home" "compress=zstd" "noatime" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/a9ba61a6-85c8-40a1-93be-31a15ab3d32c";
      fsType = "btrfs";
      options = [ "subvol=@nix" "compress=zstd" "noatime" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/47F5-8A91";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

    # swapDevices = [
    #   {
    #     device = "/swap/swapfile";
    #     size = (1024 * 16) + (1024 * 2);
    #   }
    # ];
  };
}
