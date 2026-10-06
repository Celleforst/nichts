{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.system;
in {
  options.modules.system = {
    username = mkOption {
      description = "username for this system";
      type = types.str;
    };

    gitPath = mkOption {
      description = "path to the flake directory";
      type = types.str;
    };

    cpu = mkOption {
      description = "Which manufacturer the cpu is from";
      type = types.enum ["amd" "intel"];
    };
  };

  config = {
    users.mutableUsers = true;
    users.users.${cfg.username} = {
      isNormalUser = true;
      extraGroups = ["wheel" "adbusers"];
      hashedPasswordFile = config.sops.secrets.user-password.path;
    };
  };
}
