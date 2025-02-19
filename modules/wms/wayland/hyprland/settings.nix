{
  config,
  lib,
  ...
}: let
  inherit (config.modules.system.hardware) monitors;
  inherit (lib) mapAttrsToList;
  inherit (builtins) toString;
  inherit (config.modules.style.colorScheme) colors;
in {
  config = {
    programs.hyprland = {
      settings = {
        # Hyprland settings
        "$mainMod" = "SUPER";

        # Monitor config
        # Thanks Poz for inspiration, using an attrSet is actually much smarter
        # than using a normal list.
        monitor =
          mapAttrsToList (
            name: m: let
              w = toString m.resolution.x;
              h = toString m.resolution.y;
              refreshRate = toString m.refreshRate;
              x = toString m.position.x;
              y = toString m.position.y;
              scale = toString m.scale;
            in "${name},${w}x${h}@${refreshRate},${x}x${y},${scale}"
          )
          monitors;

        # Input settings
        input = {
          kb_layout = "ch,de,us";
          kb_variant = ",,";
          kb_options = "grp:rctrl_rshift_toggle, caps:escape";

          follow_mouse = true;
	  sensitivity = 0.4;

          repeat_rate = 60;
          repeat_delay = 200;

          touchpad = {
            disable_while_typing = true;
	    natural_scroll = true;
          };
        };

        general = {
          layout = "dwindle";
          gaps_in = 5;
          gaps_out = 5;
          border_size = 1;

          "col.active_border" = "rgba(ffe1ccee) rgba(c89aeaaa) 45deg";
          "col.inactive_border" = "rgba(595959aa)";
	  resize_on_border = true;
        };

	gestures = {
	  workspace_swipe = true;
	};

        plugin = {
            hyprsplit = {
            num_workspaces = 10;
            persistent_workspaces = true;
          };
          dynamic-cursors = {
            enabled = true;

            mode = "tilt";
            tilt = {
              limit = 5000;
              function = "quadratic";
            };
            threshhold = 2;
            shake.enabled = true;
          };
	  hyprtrails.enable = true;
	  hyprexpo.enable = true;
        };
      };
    };
  };
}
