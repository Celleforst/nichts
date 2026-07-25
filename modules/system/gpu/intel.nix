{
  config,
  lib,
  ...
}: let
  cfg = config.modules.system.intel;
  inherit (lib) mkIf mkEnableOption;
in {
  options.modules.system.intel.enable = mkEnableOption "intel gpu";
  config = mkIf cfg.enable {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    boot.initrd.kernelModules = ["i915"];

    environment.sessionVariables = lib.mkIf config.modules.WM.hyprland.enable {
      XDG_SESSION_TYPE = "wayland";
      GDK_BACKEND = "wayland";
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
      NIXOS_XDG_OPEN_USE_PORTAL = "1";
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_DESKTOP = "Hyprland";
      GTK_USE_PORTAL = "1";
    };
  };
}
