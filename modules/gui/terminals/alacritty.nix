{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  username = config.modules.system.username;
  cfg = config.modules.programs.alacritty;
in {
  options.modules.programs.alacritty = {
    enable = mkEnableOption "alacritty";
    opacity = mkOption {
      description = "opacity of alacritty";
      type = types.number;
      default = 0.7;
    };
    blur = mkOption {
      description = "blur of alacritty";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.${username} = {
      home.packages = [pkgs.nerd-fonts.jetbrains-mono];

      programs.alacritty.enable = true;
      programs.alacritty.settings = {
        font = {
          size = mkForce 12;
          normal = {
            family = mkForce "JetBrainsMono Nerd Font";
            style = mkForce "Regular";
          };
        };
        window = mkForce {
          inherit (cfg) blur;
          inherit (cfg) opacity;
          padding = {
            x = 15;
            y = 15;
          };
        };
        selection.save_to_clipboard = true;
        cursor.style = mkForce {
          shape = "Beam";
          blinking = "Always";
        };
      };
    };
  };
}
