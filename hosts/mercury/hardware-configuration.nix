# PLACEHOLDER — this machine hasn't been installed yet.
# Once you've booted the install media on the real hardware, replace this
# whole file with the output of:
#   nixos-generate-config --no-filesystems --dir /tmp/mercury-hw
# (--no-filesystems because disko, driven by modules.system.disks in
# configuration.nix, generates fileSystems/swapDevices/luks.devices itself —
# hand-adding them here would conflict.)
{
  lib,
  pkgs,
  ...
}: {
  boot.initrd.availableKernelModules = [];
  boot.initrd.kernelModules = [];
  boot.kernelModules = [];
  boot.extraModulePackages = [];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
