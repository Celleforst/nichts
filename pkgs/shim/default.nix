# Vendors Debian's pre-built, Microsoft-signed shim + MokManager rather than
# getting our own shim binary through Microsoft's shim-review process —
# shim itself needs no new trust, only the GRUB it chainloads (signed with
# our own key, see modules/system/secureboot.nix) needs MOK enrollment.
# Adapted from https://github.com/WISVCH/icpc-nix/pull/22 (packages/shim.nix).
{
  stdenvNoCC,
  lib,
  fetchurl,
  binutils,
  gnutar,
  xz,
}: let
  shimSigned = fetchurl {
    url = "https://deb.debian.org/debian/pool/main/s/shim-signed/shim-signed_1.51~1+deb12u1+16.1-2~deb12u1_amd64.deb";
    hash = "sha256-wqz15VlmS7rbfOV4n5oyHzl1SjSFTTCXuMwDad9ROzs=";
  };

  shimHelpersSigned = fetchurl {
    url = "https://deb.debian.org/debian/pool/main/s/shim-helpers-amd64-signed/shim-helpers-amd64-signed_1+16.1+2~deb12u1_amd64.deb";
    hash = "sha256-JqysNRM5RsFkKgnz/aNT7juEnl/GQ/rbl6jf7J4rVfs=";
  };
in
  stdenvNoCC.mkDerivation {
    pname = "shim-signed";
    version = "1.51-16.1-2~deb12u1";

    nativeBuildInputs = [binutils gnutar xz];

    dontUnpack = true;

    buildPhase = ''
      runHook preBuild

      mkdir -p shim-signed shim-helpers-signed
      ( cd shim-signed && ar x ${shimSigned} && tar xf data.tar.xz )
      ( cd shim-helpers-signed && ar x ${shimHelpersSigned} && tar xf data.tar.xz )

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p "$out"
      install -m444 shim-signed/usr/lib/shim/shimx64.efi.signed "$out/shimx64.efi"
      install -m444 shim-helpers-signed/usr/lib/shim/mmx64.efi.signed "$out/mmx64.efi"

      runHook postInstall
    '';

    meta = with lib; {
      description = "Debian's pre-signed shim + MokManager, vendored for Secure Boot on machines without firmware key-enrollment access";
      homepage = "https://github.com/rhboot/shim";
      license = licenses.bsd2;
      platforms = ["x86_64-linux"];
    };
  }
