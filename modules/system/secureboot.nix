# Secure Boot for machines where firmware Setup/key-enrollment is locked and
# unavailable (see docs/mercury-install.md): vendors a Microsoft-signed shim
# (pkgs.shim-signed, overlay.nix) that chainloads a GRUB we sign ourselves.
# Trust is established via shim's own MOK enrollment screen, not firmware
# Setup. Adapted from https://github.com/WISVCH/icpc-nix/pull/22.
#
# The actual signing is deliberately NOT a NixOS activation step or build-time
# hook: that would make the private key a build input, i.e. a world-readable
# /nix/store/* path forever (see that PR's docs/adr/0002). Instead this just
# installs a `sign-esp` script; you run it yourself, by hand, after
# `nixos-install`/`grub-install`/any kernel update that touches /boot, reading
# the key from an ordinary runtime file path that never goes near the Nix
# store.
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.system.secureboot;
in {
  options.modules.system.secureboot = {
    enable = lib.mkEnableOption "Secure Boot via a vendored shim + self-signed GRUB (for firmware with no key-enrollment access)";

    certFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Path to the PEM public certificate to sign GRUB with and ship on the
        ESP for MOK enrollment. Public/non-sensitive -- fine to commit to the
        repo. Generate alongside the private key (kept OUTSIDE the repo and
        the Nix store) with:
          openssl req -newkey rsa:4096 -nodes -new -x509 -sha256 -days 9125 \
            -subj "/CN=nichts Secure Boot" \
            -keyout /path/outside/repo/secureboot.key \
            -out ./keys/secureboot.cer
      '';
    };

    keyFile = lib.mkOption {
      type = lib.types.str;
      default = "/root/secureboot/release.key";
      description = ''
        Runtime path (NOT a Nix path -- a plain string, never read by Nix,
        never enters the store) to the private signing key on the target
        machine. `sign-esp` reads it at the time you run it.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.certFile != null;
        message = "modules.system.secureboot.enable requires modules.system.secureboot.certFile to be set.";
      }
    ];

    # Shim expects its chainload target at a fixed path alongside itself;
    # this makes grub-install always land there instead of registering a
    # one-off NVRAM boot entry. Mutually exclusive with canTouchEfiVariables
    # (NixOS's GRUB module asserts on that combination), which auto-partition.nix
    # otherwise sets unconditionally -- override it back off here.
    boot.loader.grub.efiInstallAsRemovable = true;
    boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

    environment.systemPackages = [
      (pkgs.writeShellApplication {
        name = "sign-esp";
        runtimeInputs = with pkgs; [sbsigntool openssl coreutils];
        text = ''
          BOOT="''${1:-/boot}"
          KEY="${cfg.keyFile}"
          CERT="${cfg.certFile}"
          SHIM="${pkgs.shim-signed}"

          [ -f "$KEY" ] || { echo "error: signing key not found at $KEY" >&2; exit 1; }
          [ -f "$CERT" ] || { echo "error: signing cert not found at $CERT" >&2; exit 1; }
          [ -f "$BOOT/EFI/BOOT/BOOTX64.EFI" ] || { echo "error: $BOOT/EFI/BOOT/BOOTX64.EFI not found -- did grub-install run first?" >&2; exit 1; }

          WORK="$(mktemp -d)"
          trap 'rm -rf "$WORK"' EXIT

          cp "$BOOT/EFI/BOOT/BOOTX64.EFI" "$WORK/grubx64.efi.unsigned"
          sbsign --key "$KEY" --cert "$CERT" --output "$WORK/grubx64.efi" "$WORK/grubx64.efi.unsigned"
          sbverify --cert "$CERT" "$WORK/grubx64.efi"

          install -Dm444 "$SHIM/shimx64.efi" "$BOOT/EFI/BOOT/BOOTX64.EFI"
          install -Dm444 "$WORK/grubx64.efi" "$BOOT/EFI/BOOT/grubx64.efi"
          install -Dm444 "$SHIM/mmx64.efi" "$BOOT/EFI/BOOT/mmx64.efi"

          openssl x509 -in "$CERT" -outform DER -out "$WORK/key.cer"
          install -Dm444 "$WORK/key.cer" "$BOOT/EFI/keys/secureboot.cer"

          echo "Signed. Cert for MOK enrollment: $BOOT/EFI/keys/secureboot.cer"
          echo "Reboot, let shim drop into MokManager, pick 'Enroll key from disk', point it at that file."
        '';
      })
    ];
  };
}
