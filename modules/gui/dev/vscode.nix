{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.programs.vscode;
  username = config.modules.system.username;
in {
  options.modules.programs.vscode.enable = lib.mkEnableOption "vscode";

  config = lib.mkIf cfg.enable {
    home-manager.users.${username}.programs.vscode = {
      enable = true;
      package = pkgs.vscode;
      mutableExtensionsDir = true; # allows installing extensions (e.g. Claude) via marketplace
      profiles.default.extensions = with pkgs.vscode-extensions; [
        ms-azuretools.vscode-docker
        ms-vscode-remote.remote-ssh
        ms-vscode-remote.remote-containers
        jnoortheen.nix-ide
      ];
    };
  };
}
