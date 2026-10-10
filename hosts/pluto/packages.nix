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
    # Steam launch-options wrapper for OpenComposite: routes a game's OpenVR
    # calls straight to Monado's OpenXR runtime, bypassing vrserver/vrcompositor
    # entirely (see pluto host notes on VRInitError_Compositor_CannotDRMLeaseDisplay).
    # Use as the game's launch options: `vr-opencomposite-launch %command%`.
    (writeShellScriptBin "vr-opencomposite-launch" ''
      export VR_OVERRIDE="${opencomposite}/lib/opencomposite"
      export XR_RUNTIME_JSON="/etc/xdg/openxr/1/active_runtime.json"
      export PRESSURE_VESSEL_FILESYSTEMS_RW="$XDG_RUNTIME_DIR/monado_comp_ipc:/nix/store"
      exec "$@"
    '')
  ];
}
