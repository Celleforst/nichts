{lib, config, ...}: {
  options.nichts.build-host.enable = lib.mkEnableOption "remote build host (accept builds from other machines)";

  config = lib.mkIf config.nichts.build-host.enable {
    users.users.nix-remote-builder = {
      isSystemUser = true;
      group = "nix-remote-builder";
      shell = lib.mkDefault "/bin/sh";
      openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4gw5rnaCX8RCFB9Wo1Aru4L6I6P/MCYCeMBchMc2Tm root@saturn" ];
    };

    users.groups.nix-remote-builder = {};

    nix.settings.trusted-users = ["nix-remote-builder"];
  };
}
