_: {
  wayland.windowManager.hyprland.extraLuaFiles."windowrules" = ''
    hl.window_rule({ name = "tile-firefox",       match = { class = "^firefox$"              }, float = false })
    hl.window_rule({ name = "float-pavucontrol",  match = { class = "^pavucontrol$"          }, float = true })
    hl.window_rule({ name = "float-blueman",      match = { class = "^blueman-manager$"      }, float = true })
    hl.window_rule({ name = "float-nm",           match = { class = "^nm-connection-editor$" }, float = true })
    hl.window_rule({ name = "float-galculator",   match = { class = "^galculator$"           }, float = true })
    hl.window_rule({ name = "float-clipse",       match = { class = "^clipse$"               }, float = true })
    hl.window_rule({ name = "float-blueberry",    match = { class = "^blueberry.py$"         }, float = true })
    hl.window_rule({ name = "float-pip",          match = { title = "^Picture-in-Picture$"   }, float = true })
    hl.window_rule({ name = "pin-pip",            match = { title = "^Picture-in-Picture$"   }, pin = true })
    hl.window_rule({ name = "move-pip",           match = { title = "^Picture-in-Picture$"   }, move = "69.5% 4%" })
    hl.window_rule({ name = "size-clipse",        match = { class = "^clipse$"               }, size = "622 652" })
    hl.window_rule({ name = "stayfocused-clipse", match = { class = "^clipse$"               }, stay_focused = true })
  '';
}
