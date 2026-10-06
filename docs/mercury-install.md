# Installing NixOS on `mercury`

`mercury`'s firmware has UEFI Secure Boot mandatorily enabled (factory
default, meant for Windows) and there's no BIOS/firmware Setup access at all
-- no supervisor password, so Setup Mode, key enrollment, or even disabling
Secure Boot through firmware isn't an option. No Windows is involved; this is
Linux-only.

The approach: a self-built installer USB with a Microsoft-signed `shim.efi`
(reused from Debian, already trusted by any Secure Boot firmware) chainloading
a GRUB we sign ourselves. Trust is established via shim's own MOK enrollment
screen -- a pre-boot EFI prompt, separate from and independent of firmware
Setup. See `modules/system/secureboot.nix` for the implementation and why it
works; this doc is just the sequence of steps.

Because the installer USB and mercury's own final installed system are
signed with the **same key/cert** (`keys/secureboot.cer`, private key at
`~/.config/secureboot/release.key`), the one MOK enrollment you do while
booting the installer also covers the final system -- no second enrollment
after `nixos-install`.

## 0. The signing key (already done once, documented for next time)

```sh
mkdir -p ~/.config/secureboot
openssl req -newkey rsa:4096 -nodes -new -x509 -sha256 -days 9125 \
  -subj "/CN=nichts Secure Boot" \
  -keyout ~/.config/secureboot/release.key \
  -out keys/secureboot.cer
chmod 600 ~/.config/secureboot/release.key
```

- `release.key` is the private key. **Never commit it, never let it become a
  Nix store path.** It already exists at `~/.config/secureboot/release.key`.
- `keys/secureboot.cer` is the public certificate -- not sensitive, committed
  to the repo at `keys/secureboot.cer`.
- This key is good for ~25 years. Re-enrollment is only ever forced by a
  machine's own state resetting (reimage, different machine), not by
  rebuilding/resigning images with the same key -- so you will not need to
  redo the MOK enrollment step just because you rebuild the installer or
  reinstall mercury later.

Don't regenerate this unless the key is compromised. If you ever do, every
machine that enrolled the old cert needs re-enrollment against the new one.

## 1. Build and sign the installer USB

```sh
cd ~/nichts
nix build .#iso-img
# -> result/nixos.img (a full disk image, several GB -- builds in a VM, takes a few minutes)

SECUREBOOT_KEY=~/.config/secureboot/release.key \
SECUREBOOT_CERT=~/nichts/keys/secureboot.cer \
nix run .#sign-iso-img -- result/nixos.img
```

The sign step writes shim as the fallback EFI boot entry, your freshly-signed
GRUB alongside it, MokManager, and the DER cert (for enrollment) onto the
image's ESP. It prints `Signature verification OK` on success -- if it
doesn't, do not flash the image.

## 2. Flash it

Find the real USB device first -- **do not guess**, `dd`ing to the wrong
device destroys that disk:

```sh
lsblk
```

Then:

```sh
sudo dd if=result/nixos.img of=/dev/sdX bs=4M status=progress conv=fsync
sync
```

## 3. Boot it on mercury, enroll the key

1. Plug the USB into mercury, power on, use the one-time boot-device menu
   (not firmware Setup -- just the normal "pick a boot device" prompt,
   F12-style on most Lenovo/many other OEMs) to boot the USB.
2. Shim loads (already Microsoft-trusted) and tries to verify the GRUB
   sitting next to it. On this first boot, that verification fails -- your
   key isn't enrolled yet. Shim automatically drops into **MokManager** (a
   blue text screen), not an error dead-end.
3. Pick **"Enroll key from disk."**
4. Browse to the USB's own ESP, into `EFI/keys/`, select `secureboot.cer`.
5. Confirm "Enroll the key(s)?" -- set/accept the one-time MOK password
   prompt as asked.
6. Reboot. This time shim verifies GRUB successfully and boots straight into
   the NixOS installer environment.

From here on, trust is established for this machine -- every future image
signed with this same key (including mercury's actual installed system) just
boots, no further enrollment.

## 4. Partition and install

Inside the booted installer environment:

```sh
lsblk
ls -la /dev/disk/by-id/
```

Find mercury's real target disk's by-id path, then edit
`hosts/mercury/configuration.nix` (from the installer's own checkout of this
repo, or push the edit from elsewhere and pull it down) to replace the
placeholder:

```nix
main-disk = "/dev/disk/by-id/CHANGE_ME";  # <- replace this
```

Adjust `swap-size` to match mercury's actual RAM if `8G` isn't right.

Partition via disko (this **will destroy existing data** on that disk --
confirm it's the right device before running):

```sh
sudo nix run github:nix-community/disko -- --mode disko --flake .#mercury
```

This creates the LUKS-encrypted root, prompts you to set the disk encryption
passphrase, and mounts everything under `/mnt`.

Generate the real hardware config (kernel modules etc. -- `--no-filesystems`
because disko already declared those):

```sh
sudo nixos-generate-config --no-filesystems --root /mnt --dir /tmp/mercury-hw
```

Replace the placeholder content of `hosts/mercury/hardware-configuration.nix`
with the generated file's content (keep the file at that same path; just
swap what's inside).

Install:

```sh
sudo nixos-install --flake .#mercury
```

Set the root/user password when prompted (or confirm your sops-managed
`user-password` secret will apply -- same as every other host).

## 5. Re-sign the installed system's own GRUB

`nixos-install` runs its own `grub-install`, which writes a fresh *unsigned*
GRUB to mercury's real ESP (now mounted at `/mnt/boot` during install, `/boot`
after rebooting into the installed system). `modules.system.secureboot` is
already enabled in `hosts/mercury/configuration.nix`, so the `sign-esp`
script is already installed on the system -- run it before rebooting:

```sh
sudo sign-esp /mnt/boot
```

(or after first boot into the installed system, just `sudo sign-esp`,
defaulting to `/boot`).

Because this reuses the same cert already enrolled in step 3, **no second
MOK enrollment is needed** -- it should just boot straight through.

## 6. After it boots

- You're on a minimal, no-WM system by design (see the comment in
  `hosts/mercury/configuration.nix`) -- confirm it boots reliably a few times
  before layering a desktop environment on.
- Whenever a future NixOS generation touches the kernel/initrd/GRUB (most
  `nixos-rebuild switch` runs that bump the kernel), GRUB gets reinstalled
  unsigned again. Re-run `sudo sign-esp` after any such rebuild, before
  rebooting, or you'll be back to an unsigned GRUB that shim won't verify.
  (This is a real, recurring manual step -- there is no current automation
  for it, deliberately, so the private key never becomes a build input. See
  `modules/system/secureboot.nix`'s header comment.)
