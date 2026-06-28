{...}: {
  wayland.windowManager.hyprland.settings.env = [
    "XCURSOR_SIZE,24"
    "HYPRCURSOR_THEME,Bibata-Modern-Ice"
    "HYPRCURSOR_SIZE,24"
    "SDL_VIDEODRIVER,wayland"
    "SSH_AUTH_SOCK,$XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh"
    "XDG_SCREENSHOTS_DIR,$HOME/Pictures/screenshots"
  ];
}
