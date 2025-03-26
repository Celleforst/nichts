{inputs, ...}: let
  inherit (inputs) self;
  inherit (self) lib;
  system = "x86_64-linux";
  specialArgs = {inherit lib inputs self;};
  baseModules = [
    inputs.home-manager.nixosModules.home-manager
    inputs.disko.nixosModules.disko
    ../overlay.nix
    ../modules
  ];
in {
  iso = lib.nixosSystem {
    inherit system specialArgs;
    modules =
      baseModules ++ [./iso];
  };
  saturn = lib.nixosSystem {
    inherit system specialArgs;
    modules =
      baseModules ++ [./saturn];
  };
}
