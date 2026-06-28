{
  config,
  lib,
  ...
}: let
  cfg = config.modules.services.docker;
  username = config.modules.system.username;
in {
  options.modules.services.docker.enable = lib.mkEnableOption "docker";

  config = lib.mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      enableOnBoot = true;
    };
    users.users.${username}.extraGroups = ["docker"];
  };
}
