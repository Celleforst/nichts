# nixpkgs' monado is pinned to v25.1.0, whose `rift` driver only recognizes
# the DK2 (see src/xrt/drivers/rift/rift_prober.c) and has no positional
# tracking at all. Native Oculus Rift CV1 support -- the `rift_sensor`
# driver, doing real 6DoF constellation/LED tracking via Ceres -- landed on
# monado's git master after that tag and isn't in any release yet:
# https://gitlab.freedesktop.org/monado/monado/-/merge_requests/2748
#
# Pin to a specific commit rather than tracking master, since this is
# unreleased/unstable upstream code.
{
  monado,
  fetchFromGitLab,
  ceres-solver,
}:
monado.overrideAttrs (old: {
  version = "unstable-2026-10-07";

  src = fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "monado";
    repo = "monado";
    rev = "ec188bb137b6af93120e015a8df100046a34d8f0";
    hash = "sha256-pugCh1eYAzjSvP/NRIlc3GzhQ9TCjulyCO5lAnoUejo=";
  };

  # The v25.1.0-specific wayvr patch nixpkgs applies doesn't apply cleanly
  # (or isn't needed) against this later commit.
  patches = [];

  buildInputs = old.buildInputs ++ [ceres-solver];
})
