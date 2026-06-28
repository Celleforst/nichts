{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.programs.starship;
  username = config.modules.system.username;
in {
  options.modules.programs.starship.enable = mkEnableOption "starship";

  config = mkIf cfg.enable {
    home-manager.users.${username} = {
      programs.starship = {
        enable = true;
        enableZshIntegration = config.modules.programs.zsh.enable;
        settings = {
          add_newline = true;
          command_timeout = 1000;

          directory = {
            truncation_length = 3;
            truncate_to_repo = false;
            truncation_symbol = "…/";
            read_only = " 󰌾";
          };

          git_branch.symbol = " ";
          git_status.disabled = false;

          nix_shell = {
            symbol = " ";
            format = "[$symbol$name]($style) ";
          };

          rust.symbol = " ";
          python.symbol = " ";
          c.symbol = " ";
          nodejs.symbol = " ";

          time = {
            disabled = false;
            time_format = "%R";
            format = "[ $time]($style) ";
          };

          battery = {
            full_symbol = "󰁹";
            charging_symbol = "󰂄";
            discharging_symbol = "󰂃";
            empty_symbol = "󰂎";
            format = "[$symbol $percentage]($style) ";
            display = [
              { threshold = 15; style = "bold red"; }
              { threshold = 30; style = "yellow"; }
              { threshold = 100; style = "green"; }
            ];
          };

          character = {
            success_symbol = "[❯](bold green)";
            error_symbol = "[❯](bold red)";
          };
        };
      };
    };
  };
}
