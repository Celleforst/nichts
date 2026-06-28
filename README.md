# nichts

My personal collection of NixOS configuration files

## SOPS Setup

Secrets are managed with [sops-nix](https://github.com/Mic92/sops-nix) using age keys derived from SSH host keys.

### Setting up SOPS on your workstation (to edit secrets)

```bash
sudo ssh-to-age -private-key < /etc/ssh/ssh_host_ed25519_key > ~/.config/sops/age/keys.txt
```

### Adding a new host

1. **Deploy a minimal config first** (without services that require secrets)

2. **Get the new host's age public key:**
   ```bash
   ssh newhost "cat /etc/ssh/ssh_host_ed25519_key.pub" | ssh-to-age
   ```

3. **Add it to `.sops.yaml`:**
   ```yaml
   keys:
     - &newhost age1abc123...
   creation_rules:
     - path_regex: secrets/.*\.yaml$
       key_groups:
         - age:
             - *newhost
   ```

4. **Re-encrypt secrets for the new host:**
   ```bash
   sops updatekeys secrets/secrets.yaml
   ```

5. **Deploy the full config** — the host can now decrypt secrets using its SSH host key.

## TODO

## Project Structure

```
.
├── flake.lock
├── flake.nix
├── hosts
│   ├── common
│   │   ├── configuration.nix
│   │   ├── default.nix
│   │   └── packages.nix
│   ├── default.nix
│   ├── flocke
│   │   ├── configuration.nix
│   │   ├── default.nix
│   │   ├── hardware-configuration.nix
│   │   └── packages.nix
│   ├── iso
│   │   ├── configuration.nix
│   │   ├── default.nix
│   │   ├── hardware-configuration.nix
│   │   ├── hardware-configuration2.nix
│   │   └── packages.nix
│   └── schnee
│       ├── configuration.nix
│       ├── default.nix
│       ├── hardware-configuration.nix
│       └── packages.nix
├── LICENSE
├── modules
│   ├── cli
│   │   ├── atuin.nix
│   │   ├── default.nix
│   │   ├── fish.nix
│   │   ├── git.nix
│   │   ├── neovim.nix
│   │   ├── nh.nix
│   │   ├── ranger.nix
│   │   ├── scripts
│   │   ├── starship.nix
│   │   ├── zellij.nix
│   │   └── zsh.nix
│   ├── default.nix
│   ├── gui
│   │   ├── browsers
│   │   │   ├── default.nix
│   │   │   ├── firefox.nix
│   │   │   ├── librewolf.nix
│   │   │   └── schizofox.nix
│   │   ├── default.nix
│   │   ├── desktop
│   │   │   ├── cursor.nix
│   │   │   ├── default.nix
│   │   │   ├── greetd.nix
│   │   │   ├── gtk.nix
│   │   │   ├── qt.nix
│   │   │   ├── rofi.nix
│   │   │   ├── waybar.nix
│   │   │   └── WM
│   │   │       ├── default.nix
│   │   │       ├── hyprland.nix
│   │   │       └── i3
│   │   │           ├── default.nix
│   │   │           ├── i3-new.nix
│   │   │           └── polybar.sh
│   │   ├── dev
│   │   │   ├── default.nix
│   │   │   └── vivado.nix
│   │   ├── gaming
│   │   │   ├── default.nix
│   │   │   ├── minecraft.nix
│   │   │   ├── steam.nix
│   │   │   └── vesktop.nix
│   │   ├── media
│   │   │   ├── default.nix
│   │   │   ├── mpv.nix
│   │   │   ├── obs.nix
│   │   │   └── zathura.nix
│   │   ├── misc
│   │   │   ├── default.nix
│   │   │   └── protonvpn.nix
│   │   └── terminals
│   │       ├── alacritty.nix
│   │       ├── default.nix
│   │       ├── foot.nix
│   │       └── kitty.nix
│   ├── services
│   │   ├── default.nix
│   │   ├── firewall.nix
│   │   ├── pipewire.nix
│   │   ├── satpaper.nix
│   │   └── ssh.nix
│   ├── system
│   │   ├── auto-partition.nix
│   │   ├── bluetooth.nix
│   │   ├── default.nix
│   │   ├── fonts.nix
│   │   ├── gpu
│   │   │   ├── default.nix
│   │   │   └── nvidia.nix
│   │   ├── home-manager.nix
│   │   ├── monitors.nix
│   │   ├── network.nix
│   │   ├── nix
│   │   │   ├── default.nix
│   │   │   └── nix.nix
│   │   ├── preserve-system.nix
│   │   └── system.nix
│   ├── theming
│   │   ├── base
│   │   │   └── default.nix
│   │   ├── catppuccin
│   │   │   ├── cursor.nix
│   │   │   ├── default.nix
│   │   │   ├── firefox.nix
│   │   │   ├── hyprland.nix
│   │   │   ├── test_waybar_with_theme.sh
│   │   │   ├── waybar.css
│   │   │   └── waybar.nix
│   │   ├── default.nix
│   │   └── options.nix
│   └── tui
│       ├── btop.nix
│       ├── default.nix
│       ├── helix
│       │   ├── default.nix
│       │   ├── helix.nix
│       │   └── languages.nix
│       ├── neovim.nix
│       ├── newsboat.nix
│       └── yazi.nix
├── notes.md
├── overlay.nix
└── README.md
```
