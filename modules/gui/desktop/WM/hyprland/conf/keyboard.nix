{...}: {
  wayland.windowManager.hyprland.settings.input = {
    kb_layout = "ch,de,us";
    kb_variant = ",,";
    kb_options = "grp:rctrl_rshift_toggle,caps:escape";
    numlock_by_default = true;
    follow_mouse = true;
    mouse_refocus = false;
    accel_profile = "flat";
    force_no_accel = true;
    sensitivity = 0.4;
    repeat_rate = 50;
    repeat_delay = 200;
    touchpad = {
      natural_scroll = true;
      scroll_factor = 1.0;
      disable_while_typing = true;
    };
  };
}
