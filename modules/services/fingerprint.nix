{
  config,
  lib,
  inputs,
  ...
}: let
  cfg = config.modules.services.fingerprint;
in {
  # External driver for the Validity "Prometheus" sensor (138a:009d) --
  # stock libfprint has no driver for this chip at all. Pins its own
  # nixos-24.11 nixpkgs internally, so only import it where it's enabled.
  imports = [inputs.fingerprint-sensor.nixosModules."06cb-009a-fingerprint-sensor"];

  options.modules.services.fingerprint.enable =
    lib.mkEnableOption ''fingerprint sensor support (Validity "Prometheus" 138a:009d via python-validity/open-fprintd)'';

  config = lib.mkIf cfg.enable {
    # python-validity backend talks to the sensor via open-fprintd instead
    # of stock fprintd.
    services."06cb-009a-fingerprint-sensor" = {
      enable = true;
      backend = "python-validity";
    };

    # open-fprintd disables services.fprintd.enable, which defaults these to
    # false; open-fprintd answers the same D-Bus interface, so re-enable them.
    security.pam.services.login.fprintAuth = true;
    security.pam.services.sudo.fprintAuth = true;
    # No security.pam.services.hyprlock was defined anywhere before this, so
    # hyprlock had no /etc/pam.d/hyprlock at all and fell back to
    # /etc/pam.d/other (deny-all) -- this both fixes that and adds
    # fingerprint unlock.
    security.pam.services.hyprlock.fprintAuth = true;
    # Bitwarden desktop's "unlock with system authentication" goes through
    # Polkit -> PAM's polkit-1 service, not a direct fprintd call.
    security.pam.services.polkit-1.fprintAuth = true;

    # python-validity marks itself "suspended" going into sleep but doesn't
    # reliably reopen the USB device on resume -- the next auth attempt
    # (e.g. sudo) is what discovers this, hanging until the driver crashes
    # with "No such device" (unit ships Restart=no, so it then stays dead).
    # Restart it proactively right on resume instead of waiting for that.
    powerManagement.resumeCommands = ''
      systemctl restart python3-validity.service open-fprintd.service
    '';
    # Safety net if it dies for some other reason mid-session.
    systemd.services.python3-validity.serviceConfig = {
      Restart = "on-failure";
      RestartSec = "2";
    };

    # USB autosuspend has also been observed to drop this sensor off the
    # bus; keep it always powered.
    services.udev.extraRules = ''
      SUBSYSTEM=="usb", ATTR{idVendor}=="138a", ATTR{idProduct}=="009d", TEST=="power/control", ATTR{power/control}="on"
    '';
  };
}
