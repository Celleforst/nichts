{lib, config, ...}: {
  options.nichts.remote-builders.enable = lib.mkEnableOption "remote distributed builds";

  config = lib.mkIf config.nichts.remote-builders.enable {

    nix = {
      distributedBuilds = true;

      buildMachines = [
        {
          hostName = "server-mk.local";      # hostname or IP
          systems = ["x86_64-linux" "aarch64-linux"];
          sshUser = "nix-remote-builder";        # user on the remote with nix trusted-users
          sshKey = "/etc/nix/builder-key";       # private key readable by the nix daemon (root)
          maxJobs = 4;                           # parallel builds on this machine
          speedFactor = 10;                       # higher = preferred over slower machines
          supportedFeatures = ["nixos-test" "benchmark" "big-parallel" "kvm"];
        }
      ];

      extraOptions = lib.mkDefault ''
        fallback = true;
      '';
    };
  };
}
