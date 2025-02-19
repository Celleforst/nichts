_: {
  programs.hyprland.settings = {
    #Decoration settings
    decoration = {
      rounding = 4;
      blur = {
        enabled = true;
        size = 3;
        passes = 3;
	new_optimizations = true;
	ignore_opacity = true;
      };
      active_opacity = 1.0;
      inactive_opacity = 0.9;
    };
    # Bezier curves for aninmations.
    # Generate your own at https://www.cssportal.com/css-cubic-bezier-generator/
    bezier = [
      "wind, 0.05, 0.9, 0.1, 1.05"
      "winIn, 0.1, 1.1, 0.1, 1.1"
      "winOut, 0.3, -0.3, 0, 1"
      "liner, 1, 1, 1, 1"
    ];
    # Hyprland anomations, using the above bezier curves
    animations = {
      enabled = false;
      animation = [
        "windows, 1, 6, wind, slide"
        "windowsIn, 1, 6, winIn, slide"
        "windowsOut, 1, 5, winOut, slide"
        "border, 1, 1, liner"
        "borderangle, 1, 30, liner, loop"
        "fade, 1, 10, default"
        "workspaces, 1, 5, wind"
      ];
    };

    cursor = {
      hide_on_key_press = true;
      no_hardware_cursors = true;
    };

    misc = {
      enable_swallow = true;
      swallow_regex = "foot";
      focus_on_activate = true;
      vrr = 1;
      vfr = true;
      force_default_wallpaper = 0;
      disable_hyprland_logo = true;
      disable_splash_rendering = true;
      mouse_move_enables_dpms = true;
    };

    # Window rules for some programs.
    windowrulev2 = [
      "float, class:^(mpv)$"
      "float, class:^(imv)$"
      "float, title:^(Picture-in-Picture)$"
      "float, title:^(.*)(Choose User Profile)(.*)$"
      "float, title:^(blob:null/)(.*)$"
      "float, class:^(xdg-desktop-portal-gtk)$"
      "float, class:^(code), title: ^(Open*)"
      "size 70% 70%, class:^(code), title: ^(Open*)"
      "center, class: ^(code), title: ^(Open*)"
      "float, class:^(org.keepassxc.KeePassXC)$"
    ];
  };
}
