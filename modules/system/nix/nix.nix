{
  inputs,
  lib,
  pkgs,
  ...
}: {
  # partly taken from github.com/bloxx12/nichts

  nix = {
    package = pkgs.lix;

    registry = lib.mapAttrs (_: v: {flake = v;}) inputs;
    settings = {
      extra-experimental-features = [
        "flakes" # flakes
        "nix-command" # experimental nix commands
        "cgroups" # allow nix to execute builds inside cgroups
      ];
      substituters = [
        "https://helix.cachix.org"
        "https://nix-community.cachix.org"
        "https://hyprland.cachix.org"
        "https://nixpkgs-wayland.cachix.org"
      ];
      warn-dirty = false;
      trusted-public-keys = [
        "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCUSeBo="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "nixpkgs-wayland.cachix.org-1:NnKnit196/ozcWSySqNdObLMRqtW+xJNEHlBMRFmFfo="
      ];
    };
  };
}
