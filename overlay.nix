{inputs, ...}: let
  add_nixpkgs_small = self: super: {
    small = import inputs.nixpkgs-small {inherit (super) system;};
  };

  add_custom_scripts = self: super: {
    ani-cli-advanced = super.writeShellApplication {
      name = "ani-cli-advanced";
      runtimeInputs = with super; [ani-cli];
      text = ''
        selection=$(printf "\\ueacf Continue\n\\uf002 Search\n\\uea81 Delete History" | rofi -p "ani-cli" -dmenu -i)
        case $selection in
          *Search) ani-cli --rofi;;
          *Continue) ani-cli --rofi -c;;
          "*Delete History") ani-cli -D;;
        esac

      '';
    };
  };

  # distrobox-init writes /etc/fish/conf.d/distrobox_config.fish into every
  # container via an unquoted heredoc. Upstream bug: an unterminated quote
  # around $XDG_RUNTIME_DIR/$DBUS_SESSION_BUS_ADDRESS breaks fish's parser,
  # and several `test -z $VAR` checks are left unquoted, which fish expands
  # to zero arguments (not "") when the variable is completely unset.
  fix_distrobox_fish_init = self: super: {
    distrobox = super.distrobox.overrideAttrs (old: {
      postInstall =
        (old.postInstall or "")
        + ''
          substituteInPlace $out/bin/distrobox-init \
            --replace-fail 'test -z "\$XDG_RUNTIME_DIR && set -gx XDG_RUNTIME_DIR /run/user/(id -ru)' \
                           'test -z "\$XDG_RUNTIME_DIR" && set -gx XDG_RUNTIME_DIR /run/user/(id -ru)' \
            --replace-fail 'test -z "\$DBUS_SESSION_BUS_ADDRESS && set -gx DBUS_SESSION_BUS_ADDRESS unix:path=/run/user/(id -ru)/bus' \
                           'test -z "\$DBUS_SESSION_BUS_ADDRESS" && set -gx DBUS_SESSION_BUS_ADDRESS unix:path=/run/user/(id -ru)/bus' \
            --replace-fail 'test -z \$XAUTHORITY' 'test -z "\$XAUTHORITY"' \
            --replace-fail 'test -z \$XAUTHLOCALHOSTNAME' 'test -z "\$XAUTHLOCALHOSTNAME"' \
            --replace-fail 'test -z \$WAYLAND_DISPLAY' 'test -z "\$WAYLAND_DISPLAY"' \
            --replace-fail 'test -z \$DISPLAY' 'test -z "\$DISPLAY"'
        '';
    });
  };

  add_shim = self: super: {
    shim-signed = super.callPackage ./pkgs/shim {};
  };

  add_monado_cv1 = self: super: {
    monado-cv1 = super.callPackage ./pkgs/monado-cv1 {};
  };

  add_openxr_hello_xr = self: super: {
    openxr-hello-xr = super.callPackage ./pkgs/openxr-hello-xr {};
  };

  add_catppuccin_wallpapers = self: super: {
    catppuccin-wallpapers = super.fetchFromGitHub {
      owner = "zhichaoh";
      repo = "catppuccin-wallpapers";
      rev = "1023077979591cdeca76aae94e0359da1707a60e";
      sha256 = "sha256-h+cFlTXvUVJPRMpk32jYVDDhHu1daWSezFcvhJqDpmU=";
    };
  };
in {
  nixpkgs.overlays = [
    add_custom_scripts
    add_shim
    add_monado_cv1
    add_openxr_hello_xr
    add_catppuccin_wallpapers
    add_nixpkgs_small
    fix_distrobox_fish_init
  ];
}
