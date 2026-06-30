{lib, config, ...}: {
  options.nichts.remote-builders.enable = lib.mkEnableOption "remote distributed builds";

  config = lib.mkIf config.nichts.remote-builders.enable {

    nix = {
      distributedBuilds = true;

      buildMachines = [
        {
          hostName = "192.168.1.114";
          systems = ["x86_64-linux" "aarch64-linux"];
          sshUser = "nix-remote-builder";        # user on the remote with nix trusted-users
          sshKey = "/etc/nix/builder-key";       # private key readable by the nix daemon (root)
          maxJobs = 4;                           # parallel builds on this machine
          speedFactor = 10;                       # higher = preferred over slower machines
          supportedFeatures = ["nixos-test" "benchmark" "big-parallel" "kvm"];
        }
      ];

      settings.fallback = lib.mkDefault true;
    };

    programs.ssh.extraConfig = ''
      Host 192.168.1.114
        User nix-remote-builder
        IdentityFile /etc/nix/builder-key
        StrictHostKeyChecking accept-new
    '';
  };
}
