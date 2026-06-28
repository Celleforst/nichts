{...}: {
  wayland.windowManager.hyprland.settings = {
    dwindle = {
      preserve_split = true;
    };
    gestures = {
      gesture = [
        "3, horizontal, workspace"
        "4, down, close"
        "3, vertical, mod: SUPER, resize"
      ];
    };
    binds = {
      workspace_back_and_forth = true;
      allow_workspace_cycles = true;
      pass_mouse_when_bound = false;
    };
  };
}
