{pkgs, ...}: let
  python-packages = ps:
    with ps; [
      pandas
      numpy
      opencv4
      ipython
    ];

  qgroundcontrol-v5 = let
    appimageContents = pkgs.appimageTools.extractType2 {
      pname = "qgroundcontrol";
      version = "5.0.8";
      src = pkgs.fetchurl {
        url = "https://github.com/mavlink/qgroundcontrol/releases/download/v5.0.8/QGroundControl-x86_64.AppImage";
        hash = "sha256-BpacZ+9Y6gY97wqCcUR6HMOFQ4xKffNoEzFbRHUUZzc=";
      };
    };
  in pkgs.appimageTools.wrapType2 {
    pname = "qgroundcontrol";
    version = "5.0.8";
    src = pkgs.fetchurl {
      url = "https://github.com/mavlink/qgroundcontrol/releases/download/v5.0.8/QGroundControl-x86_64.AppImage";
      hash = "sha256-BpacZ+9Y6gY97wqCcUR6HMOFQ4xKffNoEzFbRHUUZzc=";
    };
    extraInstallCommands = ''
      install -Dm444 ${appimageContents}/org.mavlink.qgroundcontrol.desktop \
        $out/share/applications/org.mavlink.qgroundcontrol.desktop
      substituteInPlace $out/share/applications/org.mavlink.qgroundcontrol.desktop \
        --replace "Exec=QGroundControl" "Exec=qgroundcontrol"
      install -Dm444 ${appimageContents}/usr/share/icons/hicolor/128x128/apps/QGroundControl.png \
        $out/share/icons/hicolor/128x128/apps/QGroundControl.png
    '';
    meta = with pkgs.lib; {
      description = "Provides full ground station support and configuration for the PX4 and APM Flight Stacks";
      homepage = "https://qgroundcontrol.com/";
      license = licenses.gpl3Plus;
      platforms = platforms.linux;
      mainProgram = "QGroundControl";
    };
  };
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
    xrandr
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
    alacritty
    tuigreet
    claude-code
    ansible
    nmap
    net-tools
    iproute2
    iputils
    traceroute
    mtr
    tcpdump
    wireshark
    iperf3
    dig
    whois
    socat
    netcat-gnu
    ethtool
    lsof
    curl
    wget
    gnumake
    gcc
    binutils
    pkg-config
    autoconf
    automake
    foxglove-studio
    qgroundcontrol-v5
    slack
    slack
    remmina
    pre-commit
    bambu-studio
    orca-slicer
    prusa-slicer
  ];
}
