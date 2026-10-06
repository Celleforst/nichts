{pkgs, ...}: let
  mainMod = "SUPER";
  terminal = "${pkgs.alacritty}/bin/alacritty";
  files = "${pkgs.nemo}/bin/nemo";
  browser = "${pkgs.firefox}/bin/firefox";
  launcher = "rofi -show drun -show-icons";
  lock = "${pkgs.hyprlock}/bin/hyprlock";
  screenshot = "${pkgs.grimblast}/bin/grimblast";
  satty = "${pkgs.satty}/bin/satty";
  playerctl = "${pkgs.playerctl}/bin/playerctl";
  wpctl = "${pkgs.wireplumber}/bin/wpctl";
  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
  bluetuith = "${pkgs.bluetuith}/bin/bluetuith";
  clipse = "${pkgs.clipse}/bin/clipse";
in {
  wayland.windowManager.hyprland.extraLuaFiles."keybindings" = ''
    local mainMod = "${mainMod}"

    -- Applications
    hl.bind(mainMod .. " + Return",   hl.dsp.exec_cmd("${terminal}"))
    hl.bind(mainMod .. " + B",        hl.dsp.exec_cmd("${browser}"))
    hl.bind(mainMod .. " + E",        hl.dsp.exec_cmd("${files}"))
    hl.bind(mainMod .. " + M",        hl.dsp.exec_cmd("${launcher}"))
    hl.bind(mainMod .. " + CTRL + B", hl.dsp.exec_cmd("${terminal} -e ${bluetuith}"))
    hl.bind(mainMod .. " + CTRL + N", hl.dsp.exec_cmd("nm-connection-editor"))

    -- Windows
    hl.bind(mainMod .. " + C",        hl.dsp.window.close())
    hl.bind(mainMod .. " + Space",    hl.dsp.window.fullscreen())
    hl.bind(mainMod .. " + F",        hl.dsp.window.float({ action = "toggle" }))
    hl.bind(mainMod .. " + S",        hl.dsp.layout("togglesplit"))
    hl.bind(mainMod .. " + G",        hl.dsp.group.toggle())
    hl.bind(mainMod .. " + SHIFT + G", hl.dsp.group.next())

    -- Window focus (hjkl)
    hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left"  }))
    hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
    hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up"    }))
    hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down"  }))

    -- Window move (hjkl)
    hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.move({ direction = "left"  }))
    hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.move({ direction = "right" }))
    hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.move({ direction = "up"    }))
    hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.move({ direction = "down"  }))

    -- Window move by pixels (floating windows)
    hl.bind(mainMod .. " + ALT + right", hl.dsp.window.move({ x =  200, y =    0 }))
    hl.bind(mainMod .. " + ALT + left",  hl.dsp.window.move({ x = -200, y =    0 }))
    hl.bind(mainMod .. " + ALT + up",    hl.dsp.window.move({ x =    0, y = -200 }))
    hl.bind(mainMod .. " + ALT + down",  hl.dsp.window.move({ x =    0, y =  200 }))

    -- Window move to/from group
    hl.bind(mainMod .. " + ALT + h", hl.dsp.group.move_window({ direction = "left"  }))
    hl.bind(mainMod .. " + ALT + l", hl.dsp.group.move_window({ direction = "right" }))
    hl.bind(mainMod .. " + ALT + k", hl.dsp.group.move_window({ direction = "up"    }))
    hl.bind(mainMod .. " + ALT + j", hl.dsp.group.move_window({ direction = "down"  }))

    -- Window resize (hjkl)
    hl.bind(mainMod .. " + CTRL + h", hl.dsp.window.resize({ x = -50, y =   0, relative = true }))
    hl.bind(mainMod .. " + CTRL + l", hl.dsp.window.resize({ x =  50, y =   0, relative = true }))
    hl.bind(mainMod .. " + CTRL + k", hl.dsp.window.resize({ x =   0, y = -50, relative = true }))
    hl.bind(mainMod .. " + CTRL + j", hl.dsp.window.resize({ x =   0, y =  50, relative = true }))

    -- Scratchpad
    hl.bind(mainMod .. " + apostrophe",         hl.dsp.workspace.toggle_special())
    hl.bind(mainMod .. " + SHIFT + apostrophe", hl.dsp.window.move({ workspace = "special" }))

    -- Actions
    hl.bind("PRINT",                            hl.dsp.exec_cmd("${screenshot} copy area"))
    hl.bind("ALT + PRINT",                      hl.dsp.exec_cmd("${screenshot} copysave area"))
    hl.bind(mainMod .. " + SHIFT + S",          hl.dsp.exec_cmd("${screenshot} save area - | ${satty} -f -"))
    hl.bind("CTRL + ALT + L",                   hl.dsp.exec_cmd("${lock}"))
    hl.bind(mainMod .. " + L",                  hl.dsp.exec_cmd("${lock}"))
    hl.bind(mainMod .. " + Escape",             hl.dsp.exec_cmd("hypr-powermenu"))
    hl.bind(mainMod .. " + V",                  hl.dsp.exec_cmd("${terminal} --class clipse -e ${clipse}"))
    hl.bind(mainMod .. " + CTRL + R",           hl.dsp.exec_cmd("sh -c 'pkill waybar || waybar'"))
    hl.bind(mainMod .. " + CTRL + S",           hl.dsp.exec_cmd("hypr-gif-record"))
    hl.bind(mainMod .. " + SHIFT + R",          hl.dsp.exec_cmd("hyprctl reload"))
    hl.bind(mainMod .. " + CTRL + apostrophe",  hl.dsp.exec_cmd("hypr-keybindings"))

    -- Workspaces 1–10
    for i = 1, 10 do
        local key = tostring(i % 10)
        hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
        hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
    end
    hl.bind(mainMod .. " + Tab",         hl.dsp.focus({ workspace = "m+1"   }))
    hl.bind(mainMod .. " + SHIFT + Tab", hl.dsp.focus({ workspace = "m-1"   }))
    hl.bind(mainMod .. " + CTRL + Tab",  hl.dsp.focus({ workspace = "empty" }))

    -- Fn / media keys
    hl.bind("XF86MonBrightnessUp",                          hl.dsp.exec_cmd("${brightnessctl} -q s +5%"))
    hl.bind("XF86MonBrightnessDown",                        hl.dsp.exec_cmd("${brightnessctl} -q s 5%-"))
    hl.bind("SHIFT + XF86MonBrightnessUp",                  hl.dsp.exec_cmd("${brightnessctl} -q s 50%"))
    hl.bind(mainMod .. " + SHIFT + XF86MonBrightnessUp",    hl.dsp.exec_cmd("${brightnessctl} -q s 100%"))
    hl.bind("SHIFT + XF86MonBrightnessDown",                hl.dsp.exec_cmd("${brightnessctl} -q s 1%"))
    hl.bind("XF86AudioMute",    hl.dsp.exec_cmd("${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle"))
    hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("${wpctl} set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))
    hl.bind("XF86AudioPlay",    hl.dsp.exec_cmd("${playerctl} play-pause"))
    hl.bind("XF86AudioPause",   hl.dsp.exec_cmd("${playerctl} pause"))
    hl.bind("XF86AudioNext",    hl.dsp.exec_cmd("${playerctl} next"))
    hl.bind("XF86AudioPrev",    hl.dsp.exec_cmd("${playerctl} previous"))
    hl.bind("XF86ScreenSaver",  hl.dsp.exec_cmd("${lock}"), { locked = true })
    hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("${wpctl} set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true })
    hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%-"),        { repeating = true })

    -- Lid switch
    hl.bind("switch:Lid Switch", hl.dsp.exec_cmd("${lock}"), { locked = true })

    -- Mouse move/resize
    hl.bind(mainMod .. " + SHIFT + mouse:272", hl.dsp.window.drag(),   { mouse = true })
    hl.bind(mainMod .. " + mouse:273",         hl.dsp.window.resize(), { mouse = true })

    -- Passthru submap (forward all keys to focused VM/app)
    hl.bind(mainMod .. " + CTRL + P", hl.dsp.submap("passthru"))
    hl.define_submap("passthru", function()
        hl.bind(mainMod .. " + CTRL + BackSpace", hl.dsp.submap("reset"))
    end)
  '';
}
