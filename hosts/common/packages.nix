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
    eza # exa is unmaintained
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
    alejandra # nix formatter
  ];
}
