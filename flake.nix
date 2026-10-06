{
  description = "My personal NixOS configuration";
  outputs = inputs @ {
    self,
    nixpkgs,
    nixos-generators,
    ...
  }: let
    system = "x86_64-linux";
  in {
    inherit (nixpkgs) lib;
    nixosConfigurations = import ./hosts {inherit inputs;};

    # nix build .#iso-img -> result/nixos.img, flash with:
    #   sudo dd if=result/nixos.img of=/dev/sdX bs=4M status=progress conv=fsync
    # Then sign it (Secure Boot, see modules/system/secureboot.nix and
    # scripts/sign-image.sh) before booting it on a locked machine:
    #   nix run .#sign-iso-img -- result/nixos.img
    packages.${system}.iso-img = nixos-generators.nixosGenerate {
      inherit system;
      specialArgs = {
        inherit (nixpkgs) lib;
        inherit inputs self;
      };
      format = "raw-efi";
      modules = [
        inputs.home-manager.nixosModules.home-manager
        inputs.disko.nixosModules.disko
        inputs.sops-nix.nixosModules.sops
        inputs.forticlient-nixos.nixosModules.forticlient
        ./overlay.nix
        ./modules
        ./hosts/common
        ./hosts/iso/configuration.nix
        {
          # raw-efi builds its own disk image + filesystem layout; the
          # disko-based real-disk install path hosts/iso/configuration.nix
          # otherwise uses would conflict with it.
          modules.system.disks.auto-partition.enable = nixpkgs.lib.mkForce false;

          # The image is assembled in an ephemeral build VM with no access to
          # the host's sops age key, so the user-password secret can't
          # decrypt there -- hashedPasswordFile would otherwise silently win
          # over hosts/iso's intentional `password = ""` (see the precedence
          # order NixOS prints for this). Force it off so empty-password
          # login actually works on the built image.
          users.users.mk.hashedPasswordFile = nixpkgs.lib.mkForce null;
        }
      ];
    };

    apps.${system}.sign-iso-img = {
      type = "app";
      program = let
        pkgs = nixpkgs.legacyPackages.${system};
        shim = pkgs.callPackage ./pkgs/shim {};
      in
        toString (pkgs.writeShellApplication {
          name = "sign-iso-img";
          runtimeInputs = with pkgs; [mtools sbsigntool openssl jq util-linux gnugrep coreutils];
          text = ''
            export SHIM_DIR="${shim}"
            exec ${./scripts/sign-image.sh} "$@"
          '';
        })
        + "/bin/sign-iso-img";
    };
  };
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # nixpkgs-small receives pull requests faster
    nixpkgs-small.url = "github:NixOS/nixpkgs/nixos-unstable-small";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin.url = "github:catppuccin/nix";

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    satpaper = {
      url = "github:Dragyx/satpaper";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    forticlient-nixos.url = "github:jplana/forticlient-nixos";

    # Driver for Validity "Prometheus" fingerprint sensors (saturn's 138a:009d)
    # that stock libfprint can't drive. Pins its own nixos-24.11 nixpkgs
    # internally, so deliberately not following the main nixpkgs input here.
    fingerprint-sensor.url = "github:ahbnr/nixos-06cb-009a-fingerprint-sensor/25.05";

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-cosmic.url = "github:lilyinstarlight/nixos-cosmic";
    # nixpkgs.follows = "nixos-cosmic/nixpkgs";
  };
}
