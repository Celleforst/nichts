{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: let
  username = config.modules.system.username;
  cfg = config.modules.theming.themes.stylix;
  inherit (lib) mkIf mkOption types;
in {
  imports = [inputs.stylix.nixosModules.stylix];

  options.modules.theming.themes.stylix = {
    scheme = mkOption {
      type = types.str;
      default = "gruvbox-dark-hard";
      description = "base16 scheme name from pkgs.base16-schemes (e.g. gruvbox-dark-hard, nord, tokyo-night-dark, rose-pine, kanagawa)";
    };
    image = mkOption {
      type = types.path;
      description = "Wallpaper image path used by Stylix for lockscreen and color generation";
    };
  };

  config = mkIf cfg.enable {
    stylix = {
      enable = true;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/${cfg.scheme}.yaml";
      inherit (cfg) image;

      fonts = {
        monospace = {
          package = pkgs.nerd-fonts.jetbrains-mono;
          name = "JetBrainsMono Nerd Font";
        };
        sansSerif = {
          package = pkgs.noto-fonts;
          name = "Noto Sans";
        };
        serif = {
          package = pkgs.noto-fonts;
          name = "Noto Serif";
        };
        emoji = {
          package = pkgs.noto-fonts-color-emoji;
          name = "Noto Color Emoji";
        };
      };
    };

    home-manager.users.${username}.stylix.targets.hyprland.enable = false;
  };
}
