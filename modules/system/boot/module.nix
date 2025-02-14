{pkgs, ...}: {
  boot.loader = {
    efi.canTouchEfiVariables = true;
    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
      configurationLimit = 5;
    };
  };
  boot.plymouth = {
    enable = true;
    # font = "${pkgs.jetbrains-mono}/share/fonts/truetype/JetBrainsMono-Regular.ttf";
    themePackages = [pkgs.catppuccin-plymouth];
    theme = "catppuccin-macchiato";
  };
}
