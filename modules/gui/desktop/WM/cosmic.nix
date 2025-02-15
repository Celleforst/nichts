{
  inputs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.WM.cosmic;
  inherit (lib) mkEnableOption mkIf;
in {
  imports = [
    inputs.nixos-cosmic.nixosModules.default
  ];

  options.modules.WM.cosmic.enable = mkEnableOption "cosmic";

  config = mkIf cfg.enable {
    # see https://github.com/lilyinstarlight/nixos-cosmic
    nix.settings = {
      substituters = ["https://cosmic.cachix.org/"];
      trusted-public-keys = ["cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE="];
    };
  };
}
