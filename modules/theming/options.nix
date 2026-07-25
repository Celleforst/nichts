{
  config,
  lib,
  ...
}:
with lib; let
  username = config.modules.system.username;
  cfg = config.modules.theming;
in {
  config = {
    modules.theming.themes.catppuccin.enable = cfg.theme == "catppuccin";
    modules.theming.themes.stylix.enable = cfg.theme == "stylix";
  };
  options = {
    modules.theming = {
      theme = mkOption {
        type = with types;
          nullOr (
            enum ["catppuccin" "stylix"]
          );
        default = null;
        example = "catppuccin";
        description = "Select which system wide theme to use";
      };
      themes = {
        catppuccin.enable = mkEnableOption "catppuccin";
        stylix.enable = mkEnableOption "stylix";
      };
    };
  };
}
