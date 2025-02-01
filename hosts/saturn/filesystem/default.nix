{
  config = {
    boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-uuid/d51ce0fa-8c62-4b38-b6b8-1671f7088c59";
    fileSystems = {
      "/boot" = {
        device = "/dev/disk/by-uuid/05A5-1011";
        fsType = "vfat";
      };
      
      "/" = {
        device = "/dev/disk/by-uuid/d51ce0fa-8c62-4b38-b6b8-1671f7088c59";
        fsType = "btrfs";
        options = ["compress=zstd" "noatime"];
      };
      "/nix" = {
        device = "/dev/disk/by-uuid/d51ce0fa-8c62-4b38-b6b8-1671f7088c59";
        fsType = "btrfs";
        options = ["subvol=nix" "compress=zstd" "noatime"];
      };
      "/home" = {
        device = "/dev/disk/by-uuid/d51ce0fa-8c62-4b38-b6b8-1671f7088c59";
        fsType = "btrfs";
        options = ["subvol=home" "compress=zstd" "noatime"];
      };
    };
    # swapDevices = [
    #   {
    #     device = "/swap/swapfile";
    #     size = (1024 * 16) + (1024 * 2);
    #   }
    # ];
  };
}
