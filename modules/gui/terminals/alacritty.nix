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
      home.packages = [ pkgs.nerd-fonts.jetbrains-mono ];

      programs.alacritty.enable = true;
      programs.alacritty.settings = {
        font = {
          size = 12.0;
          normal = {
            family = "JetBrainsMono Nerd Font";
            style = "Regular";
          };
        };
        window = {
          blur = cfg.blur;
          opacity = cfg.opacity;
          padding = { x = 15; y = 15; };
        };
        selection.save_to_clipboard = true;
        cursor.style = {
          shape = "Beam";
          blinking = "Always";
        };
        keyboard.bindings = [
          {
            key = "Return";
            mods = "Shift";
            # sends ESC + CR, useful in terminal multiplexers
            chars = builtins.fromJSON "\"\\u001B\\r\"";
          }
        ];
      };
    };
  };
}
