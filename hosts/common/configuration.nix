{
  config,
  pkgs,
  lib,
  ...
}: let
  username = config.modules.other.system.username;
  mkFirefoxExtension = name: id: {
    name = id;
    value = {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/${name}/latest.xpi";
      installation_mode = "force_installed";
    };
  };

in {
  imports = [
    ../../options/common/pin-registry.nix
    ../../options/common/preserve-system.nix
    ../../options/desktop/fonts.nix
  ];

  # use zsh as default shell
  users.users.${username}.shell = pkgs.zsh;
  home-manager.backupFileExtension = "bak";
  users.defaultUserShell = pkgs.zsh;
  networking.dhcpcd.wait = "background";
  services.locate = {
    enable = true;
    interval = "hourly";
    package = pkgs.plocate;
    localuser = null;
  };

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = "experimental-features = nix-command flakes";
  };

  modules = {
    programs = {
      foot.enable = lib.mkDefault true;
      foot.server = lib.mkDefault true;
      nh.enable = lib.mkDefault true;
      atuin.enable = lib.mkDefault true;
      firefox.extensions = lib.listToAttrs [
        (mkFirefoxExtension "bitwarden-password-manager" "{446900e4-71c2-419f-a6a7-df9c091e268b}")
        (mkFirefoxExtension "darkreader" "addon@darkreader.org")
        (mkFirefoxExtension "tree-style-tab" "treestyletab@piro.sakura.ne.jp")
        (mkFirefoxExtension "vvz-coursereview" "{64a9abc5-b0dd-4855-831c-7b73290c0613}")
        (mkFirefoxExtension "privacy-badger17" "jid1-MnnxcxisBPnSXQ@jetpack")
      ];
    };
    
  };

  time.timeZone = "Europe/Zurich";
}
