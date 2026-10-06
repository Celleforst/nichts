#!/usr/bin/env bash
# Signs an already-built raw-efi image's ESP in place, via mtools (no
# loop-mount, no root). Adapted from
# https://github.com/WISVCH/icpc-nix/pull/22 (scripts/sign-image.sh) --
# see that PR's docs/adr/0002-sign-images-post-build.md for why this is a
# separate post-build step rather than a Nix build-time hook: doing it
# inside the derivation would make the private key a build input, i.e. a
# world-readable /nix/store/* path forever.
#
# Usage:
#   SHIM_DIR=<path to pkgs/shim output> \
#   SECUREBOOT_KEY=<path to the private signing key> \
#   SECUREBOOT_CERT=<path to the signing certificate> \
#   sign-image.sh <path to a writable raw-efi image>
set -euo pipefail

usage() {
  echo "Usage: SHIM_DIR=<dir> SECUREBOOT_KEY=<file> SECUREBOOT_CERT=<file> $0 <image.img>" >&2
}

if [ "$#" -ne 1 ]; then
  usage
  exit 1
fi
IMAGE="$1"

: "${SHIM_DIR:?SHIM_DIR must point to the built shim package (shimx64.efi, mmx64.efi)}"
: "${SECUREBOOT_KEY:?SECUREBOOT_KEY must point to the private signing key file}"
: "${SECUREBOOT_CERT:?SECUREBOOT_CERT must point to the signing certificate file}"

[ -f "$IMAGE" ] || { echo "error: image not found: $IMAGE" >&2; exit 1; }
[ -w "$IMAGE" ] || { echo "error: image not writable: $IMAGE" >&2; exit 1; }
[ -f "$SHIM_DIR/shimx64.efi" ] || { echo "error: $SHIM_DIR/shimx64.efi not found" >&2; exit 1; }
[ -f "$SHIM_DIR/mmx64.efi" ] || { echo "error: $SHIM_DIR/mmx64.efi not found" >&2; exit 1; }
[ -f "$SECUREBOOT_KEY" ] || { echo "error: signing key not found: $SECUREBOOT_KEY" >&2; exit 1; }
[ -f "$SECUREBOOT_CERT" ] || { echo "error: signing cert not found: $SECUREBOOT_CERT" >&2; exit 1; }

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# Locate the ESP partition's byte offset within the raw disk image, so
# mtools can address it directly without mounting anything.
ESP_OFFSET="$(
  sfdisk -J "$IMAGE" | jq -r '
    .partitiontable as $t
    | ($t.sectorsize // 512) as $ss
    | ($t.partitions[]
        | select((.type | ascii_downcase) == "c12a7328-f81f-11d2-ba4b-00a0c93ec93b" or (.type | ascii_downcase) == "0xef" or (.type | ascii_downcase) == "ef")
        | .start) * $ss
  ' | head -n1
)"
if [ -z "$ESP_OFFSET" ]; then
  echo "error: no ESP partition found in $IMAGE" >&2
  exit 1
fi

MTOOLS_IMG="${IMAGE}@@${ESP_OFFSET}"
export MTOOLS_SKIP_CHECK=1

mdir_i() { mdir -i "$MTOOLS_IMG" "$@"; }
mcopy_i() { mcopy -i "$MTOOLS_IMG" "$@"; }
mdel_i() { mdel -i "$MTOOLS_IMG" "$@"; }
mmd_i() { mmd -i "$MTOOLS_IMG" "$@"; }

echo "== ESP /EFI/BOOT before signing ==" >&2
mdir_i "::/EFI/BOOT" >&2

# nixos-generators' raw-efi format (efiInstallAsRemovable = true) installs
# the plain, unsigned GRUB binary as the default boot entry. FAT short names
# are case-insensitive, so mtools matches this regardless of on-disk case.
if ! mcopy_i "::/EFI/BOOT/BOOTX64.EFI" "$WORK/grubx64.efi.unsigned"; then
  echo "error: EFI/BOOT/BOOTX64.EFI not found on ESP" >&2
  exit 1
fi

sbsign --key "$SECUREBOOT_KEY" --cert "$SECUREBOOT_CERT" \
  --output "$WORK/grubx64.efi" "$WORK/grubx64.efi.unsigned"

mdel_i "::/EFI/BOOT/BOOTX64.EFI"
mdel_i "::/EFI/BOOT/grubx64.efi" 2>/dev/null || true
mdel_i "::/EFI/BOOT/mmx64.efi" 2>/dev/null || true

mcopy_i -o "$SHIM_DIR/shimx64.efi" "::/EFI/BOOT/BOOTX64.EFI"
mcopy_i -o "$WORK/grubx64.efi" "::/EFI/BOOT/grubx64.efi"
mcopy_i -o "$SHIM_DIR/mmx64.efi" "::/EFI/BOOT/mmx64.efi"

openssl x509 -in "$SECUREBOOT_CERT" -outform DER -out "$WORK/secureboot.cer"
mmd_i "::/EFI/keys" 2>/dev/null || true
mcopy_i -o "$WORK/secureboot.cer" "::/EFI/keys/secureboot.cer"

echo "== ESP /EFI after signing ==" >&2
mdir_i -/ "::/EFI" >&2

mcopy_i "::/EFI/BOOT/grubx64.efi" "$WORK/grubx64.efi.verify"
if ! sbverify --cert "$SECUREBOOT_CERT" "$WORK/grubx64.efi.verify" >&2; then
  echo "error: signature verification failed on the signed grubx64.efi" >&2
  exit 1
fi

echo "OK: $IMAGE signed (shim + signed grubx64.efi; cert at EFI/keys/secureboot.cer)" >&2
