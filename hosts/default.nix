{inputs, ...}: let
  inherit (inputs) self;
  inherit (self) lib;
  system = "x86_64-linux";
  specialArgs = {inherit lib inputs self;};
  baseModules = [
    inputs.home-manager.nixosModules.home-manager
    inputs.disko.nixosModules.disko
    inputs.sops-nix.nixosModules.sops
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
  pluto = lib.nixosSystem {
    inherit system specialArgs;
    modules =
      baseModules ++ [./pluto];
  };
}
