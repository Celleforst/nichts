{pkgs, ...}: let
  python-packages = ps:
    with ps; [
      pandas
      numpy
      opencv4
      ipython
    ];
in {
  environment.systemPackages = with pkgs; [
    (python3.withPackages python-packages)
    xrandr
    wine
    cloudflared
    ryubing
    eden
    lutris
    winetricks
    wine-staging
  ];
}
