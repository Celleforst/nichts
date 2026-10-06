_: {
  wayland.windowManager.hyprland.extraLuaFiles."env" = ''
    hl.env("XCURSOR_SIZE",        "24")
    hl.env("HYPRCURSOR_THEME",    "Bibata-Modern-Ice")
    hl.env("HYPRCURSOR_SIZE",     "24")
    hl.env("SDL_VIDEODRIVER",     "wayland")
    hl.env("SSH_AUTH_SOCK",       os.getenv("XDG_RUNTIME_DIR") .. "/gnupg/S.gpg-agent.ssh")
    hl.env("XDG_SCREENSHOTS_DIR", os.getenv("HOME") .. "/Pictures/screenshots")
  '';
}
