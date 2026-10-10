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
    monado-cv1
    openxr-hello-xr
    opencomposite
    # One-off registration of Monado's bundled SteamVR driver plugin with
    # SteamVR's path registry -- run once after SteamVR has been installed
    # and launched at least once (vrpathreg only exists after that).
    (writeShellScriptBin "monado-steamvr-register" ''
      exec "$HOME/.steam/steam/steamapps/common/SteamVR/bin/linux64/vrpathreg" \
        adddriver ${monado-cv1}/share/steamvr-monado
    '')
  ];
}
