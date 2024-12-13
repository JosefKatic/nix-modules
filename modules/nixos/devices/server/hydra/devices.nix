{
  config,
  lib,
  pkgs,
  ...
}: let
  mkBuildMachine = {
    uri ? null,
    systems ? null,
    sshKey ? null,
    maxJobs ? null,
    speedFactor ? null,
    supportedFeatures ? null,
    mandatoryFeatures ? null,
    publicHostKey ? null,
  }: let
    field = x:
      if (x == null || x == [] || x == "")
      then "-"
      else if (builtins.isInt x)
      then (builtins.toString x)
      else if (builtins.isList x)
      then (builtins.concatStringsSep "," x)
      else x;
  in ''
    ${field uri} ${field systems} ${field sshKey} ${field maxJobs} ${field speedFactor} ${field supportedFeatures} ${field mandatoryFeatures} ${field publicHostKey}
  '';

  buildMachinesFile = builtins.concatStringsSep "\n" (map mkBuildMachine [
    {
      uri = "ssh://nix-ssh@alcedo";
      systems = [
        "x86_64-linux"
      ];
      sshKey = config.sops.secrets.nix-ssh-key.path;
      maxJobs = 6;
      speedFactor = 50;
      supportedFeatures = [
        "kvm"
        "big-parallel"
        "nixos-test"
      ];
    }
    {
      uri = "ssh://nix-ssh@falco";
      systems = [
        "aarch64-linux"
      ];
      sshKey = config.sops.secrets.nix-ssh-key.path;
      maxJobs = 6;
      speedFactor = 50;
      supportedFeatures = [
        "kvm"
        "big-parallel"
        "nixos-test"
      ];
    }
    {
      uri = "ssh://nix-ssh@regulus";
      systems = [
        "x86_64-linux"
      ];
      sshKey = config.sops.secrets.nix-ssh-key.path;
      maxJobs = 2;
      speedFactor = 20;
      supportedFeatures = [
        "kvm"
        "big-parallel"
        "nixos-test"
      ];
    }
    {
      uri = "localhost";
      systems = [
        "aarch64-linux"
        "x86_64-linux"
      ];
      maxJobs = 4;
      speedFactor = 50;
      supportedFeatures = [
        "kvm"
        "big-parallel"
        "nixos-test"
      ];
    }
  ]);
in {
  config = lib.mkIf config.device.server.hydra.enable {
    services.hydra.buildMachinesFiles = ["/etc/nix/hydra-machines"];
    systemd = {
      timers.builder-pinger = {
        description = "Build machine pinger timer";
        partOf = ["builder-pinger.service"];
        wantedBy = ["multi-user.target"];
        timerConfig = {
          OnBootSec = "0";
          OnUnitActiveSec = "30s";
        };
      };
      services.builder-pinger = {
        description = "Build machine pinger";
        enable = true;
        wantedBy = [
          "multi-user.target"
          "post-resume.target"
        ];
        serviceConfig = {
          Type = "oneshot";
          Restart = "no";
        };
        path = [
          config.nix.package
          config.programs.ssh.package
          pkgs.diffutils
          pkgs.coreutils
        ];
        script = ''
          set -euo pipefail

          final_file="/etc/nix/hydra-machines"
          temp_file="$(mktemp)"

          check_host() {
            line="$1"
            host="$(echo "$line" | cut -d ' ' -f1)"
            key="$(echo "$line" | cut -d ' ' -f3)"

            if [ "$key" == "-" ]; then
                args=""
            else
                args="ssh-key=$key"
            fi
            if [ "$host" == "localhost" ]; then
                host="local"
            fi

            if timeout 20 nix store ping  --store "$host?$args"; then
                echo "$line" >> $temp_file
            fi
          }

          while read -r host_line; do
            check_host "$host_line" &
          done < "${builtins.toFile "machines" buildMachinesFile}"

          wait

          touch "$final_file"
          if ! diff <(sort "$temp_file") <(sort "$final_file"); then
            mv "$temp_file" "$final_file"
            chmod 755 "$final_file"
            touch "$final_file" # So that hydra-queue-runner refreshes
          fi
        '';
      };
    };
  };
}
