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
    # In-VR dashboard/overlay, OpenXR-native so it works directly against
    # Monado without needing SteamVR's compositor at all (unlike SteamVR's
    # own dashboard, which is blocked by the same VRInitError_Compositor_
    # CannotDRMLeaseDisplay issue documented elsewhere on this host). Also
    # has a playspace mover, which should be a much better way to fix the
    # room-centering/origin mismatch than vr-room-setup's recenter step --
    # live and adjustable in VR, no service restart needed.
    wayvr
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
      # /run/host/etc inside the pressure-vessel sandbox maps to the *Steam
      # FHS wrapper's own* bundled /etc (steam-fhsenv-rootfs), not the real
      # NixOS host /etc -- so /run/host/etc/xdg/openxr/... never exists there.
      # Point straight at Monado's manifest in the Nix store instead, which
      # PRESSURE_VESSEL_FILESYSTEMS_RW already exposes unchanged.
      export XR_RUNTIME_JSON="${monado-cv1}/share/openxr/1/openxr_monado.json"
      export PRESSURE_VESSEL_FILESYSTEMS_RW="$XDG_RUNTIME_DIR/monado_comp_ipc:/nix/store"
      # Room-scale games ask for XR_REFERENCE_SPACE_TYPE_STAGE, which is a
      # separate space from LOCAL/LOCAL_FLOOR -- monado-ctl -c (vr-room-setup's
      # recenter step) only recenters the latter, so without this, recentering
      # visibly does nothing for games like The Lab. This quirk makes Monado
      # treat stage as local_floor so they move together.
      export OXR_RECENTER_STAGE=1
      {
        echo "=== $(date -Iseconds) ==="
        env
        echo "--- argv ---"
        printf '%s\n' "$@"
      } >> /tmp/vr-opencomposite-launch.log
      exec "$@"
    '')
    # Guided room setup: this unreleased constellation tracker doesn't persist
    # its outside-in rig calibration (or the Touch controllers' separate LED
    # correspondence lock) between runs -- restarting monado.service always
    # starts cold, on both fronts. And no in-game "recenter" binding seems to
    # reach Monado through OpenComposite, even though monado-ctl already has
    # a recenter mode (-c, the same mnd_root_recenter_local_spaces() a game's
    # recenter button would call) -- it's just not bound to anything. Runs
    # hello_xr as a disposable OpenXR client in the background for the
    # duration, since the tracking/compositor pipeline wants an active
    # session rather than an idle service, so none of this needs Steam or the
    # real game running first.
    (writeShellScriptBin "vr-room-setup" ''
      set -e

      echo "Restarting monado.service for a clean calibration state..."
      systemctl --user restart monado.service

      echo "Starting a throwaway OpenXR session to keep tracking active during setup..."
      echo "(also renders a small cube at each locked controller's pose -- put the"
      echo " headset on now and keep it on through the steps below.)"
      ${openxr-hello-xr}/bin/hello_xr -g Vulkan2 >/tmp/vr-room-setup-hello_xr.log 2>&1 &
      hello_xr_pid=$!
      trap 'kill "$hello_xr_pid" 2>/dev/null || true' EXIT
      sleep 2

      echo
      echo "Step 1: rig calibration."
      echo "With the headset on, move your head through all axes (tilt, turn, a"
      echo "little side-to-side) for a few seconds, until tracking feels stable"
      echo "rather than jumpy."
      read -rp "Press Enter once that feels locked in... "

      echo
      echo "Step 2: controller lock."
      echo "Each controller needs its own lock, separate from the headset's --"
      echo "there's no automated way to check this, so use hello_xr's own cube:"
      echo "hold the LEFT controller up in view of both sensors and move it"
      echo "gently. A small cube should appear and track it smoothly once locked"
      echo "(if nothing appears, or it's frozen, keep moving the controller)."
      read -rp "Press Enter once you see the left controller's cube tracking... "
      echo "Now the RIGHT controller, the same way."
      read -rp "Press Enter once you see the right controller's cube tracking... "

      echo
      echo "Step 3: recenter."
      echo "Put the headset on and stand where you want the play area centered,"
      echo "facing the direction you want to be \"forward\"."
      read -rp "Press Enter to recenter to your current position... "

      ${monado-cv1}/bin/monado-ctl -c
      echo "Recentered. You can now launch the game."
    '')
  ];
}
