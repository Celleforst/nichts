{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    mokutil
  ];
}
