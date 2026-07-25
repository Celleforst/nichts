# which default packages to use for the system
{pkgs, ...}: let
  python-packages = ps:
    with ps; [
    ];
in {
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    (python3.withPackages python-packages)
    vim
    bat
    neovim
    eza
    hwinfo
    git
    unzip
    calc
    rsync
    # wlr-randr
    wget
    python3
    gcc
    htop
    nix-index
    tldr
    parted
    dig
    alejandra # nix formatter
    statix # nix linter
    deadnix # nix dead-code finder
    gitleaks # secret leak detection
    smartmontools
    tmux
    lsof
    sops
    ethtool
    xeyes
    cloudflared
    lshw
    usbutils
    dua
  ];
}
