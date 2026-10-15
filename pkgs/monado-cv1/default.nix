# nixpkgs' monado is pinned to v25.1.0, whose `rift` driver only recognizes
# the DK2 (see src/xrt/drivers/rift/rift_prober.c) and has no positional
# tracking at all. Native Oculus Rift CV1 support -- the `rift_sensor`
# driver, doing real 6DoF constellation/LED tracking via Ceres -- landed on
# monado's git master after that tag and isn't in any release yet:
# https://gitlab.freedesktop.org/monado/monado/-/merge_requests/2748
#
# Pin to a specific commit rather than tracking master, since this is
# unreleased/unstable upstream code.
#
# Built from unreleased main (ec188bb1) first, but that commit hardcodes an
# *identical* pose_in_origin for every sensor ("HACK ... until we have real
# room calibration" in target_builder_rift.c) -- with our 2 sensors mounted
# side by side, that made the tracker treat them as colocated, alternately
# trusting each one's (differently wrong) solve as the headset moved,
# visible as the pose jumping between two positions while moving (fine while
# still). A hand-patched per-sensor offset improved but didn't fix it.
#
# Switched to MR !3015 (still unmerged, branch feature/room-setup on a fork)
# which replaces that hack with real outside-in rig calibration + sensor
# fusion (has_concrete_pose = false now; poses are solved at runtime instead
# of assumed). This is a much larger, actively-developed change with
# upstream-acknowledged rough edges: rig calibration needs the headset in
# clear view of all cameras to lock on, fast motion can lose controller
# tracking, occlusion causes mis-locks, and -- important -- the rig
# calibration is NOT persisted between runs, so it has to be redone (hold
# the headset so all cameras can see it, move it gently through all axes
# until the debug view shows tracking lock) every time monado.service starts.
# Separately: Touch controller position is not tracked at all by this
# branch (or main) -- confirmed by reading src/xrt/drivers/rift/rift_radio.c,
# rift_touch_controller_get_tracked_pose only ever sets orientation, and
# target_builder_rift.c never adds Touch controllers to the constellation
# tracker in the first place. That's an architectural gap, not a bug.
#
# Tried routing through OpenHMD instead (thaytan/OpenHMD, branch
# rift-room-config, via Monado's built-in -- normally unused -- OHMD driver
# path), since that's the only other place open-source CV1 Touch 6DoF
# tracking exists at all (confirmed independently in thaytan/OpenHMD#54).
# Worked, but regressed both halves: HMD tracking got noticeably less
# stable than this branch's own rig calibration, and the controllers
# themselves drifted, both traced to a constant stream of "mismatched LED
# id" correspondence failures in OpenHMD's own blob matching. Reverted.
#
# touch-controller-constellation-tracking.patch instead wires Touch
# controllers into *this* branch's constellation tracker directly, the same
# way the HMD already is -- new LED model built from the calibration data
# rift_touch_calibration.cpp was already parsing (just never fed to the
# tracker), lazy device registration once that calibration arrives
# asynchronously over radio, and the HMD's own pose passed as a search prior
# to help correspondence search (aimed at the same class of "mismatched LED
# id" issue seen with OpenHMD).
{
  monado,
  fetchFromGitLab,
  ceres-solver,
}:
monado.overrideAttrs (old: {
  version = "unstable-2026-10-03-room-setup";

  src = fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "Beyley";
    repo = "monado";
    rev = "0fc83b90c75e5b06743da3981fb554e7da55e90a";
    hash = "sha256-sd2W015Q86+RTX+vAutqIYIhp0EKfZY9mafQJ98pIE0=";
  };

  # The v25.1.0-specific wayvr patch nixpkgs applies doesn't apply cleanly
  # (or isn't needed) against this later commit.
  patches = [./touch-controller-constellation-tracking.patch];

  buildInputs = old.buildInputs ++ [ceres-solver];
})
