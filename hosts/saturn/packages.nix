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
    vlc
    material-icons
    material-design-icons
    libreoffice
    spotify
    hyprland-protocols
    feh
    xorg.xrandr 
    wine
    # easyeffects
    nautilus
    alsa-utils
    foot
    gimp 
    imagemagick
    glow # cli markdown viewer
    hunspell
    hunspellDicts.en_US
    hunspellDicts.de_AT
  ];
}
