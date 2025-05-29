{
  config,
  inputs,
  pkgs,
  lib,
  ...
}: let
  cfg = config.company.autoUpgrade;
  # Only enable auto upgrade if current config came from a clean tree
  # This avoids accidental auto-upgrades when working locally.
in {
  options = {
    company.autoUpgrade.user = {
      enable = lib.mkEnableOption "periodic hydra-based auto upgrade";
      job = lib.mkOption {
        type = lib.types.str;
        default = "users.$USER@${config.networking.hostName}";
      };
    };
  };

  config = lib.mkIf cfg.user.enable {
    assertions = [
      {
        assertion = cfg.user.enable -> !config.system.autoUpgrade.enable;
        message = ''
          hydraAutoUpgrade and autoUpgrade are mutually exclusive.
        '';
      }
    ];

    systemd.user.services.home-manager-first-setup = {
      wantedBy = ["graphical-session.target"];
      wants = ["nix-daemon.socket" "network-online.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = false;
      };
      path = with pkgs; [
        config.nix.package.out
        config.programs.ssh.package
        coreutils
        curl
        gitMinimal
        gnutar
        gzip
        jq
        nvd
      ];
      script = let
        buildUrl = "${cfg.instance}/job/${cfg.project}/${cfg.jobset}/${cfg.user.job}/latest";
      in ''
         profile="$HOME/.local/state/nix/profiles/home-manager"
         if [ -e $profile ]; then
           echo "Home manager profile exists."
           exit 0;
         fi

         eval="$(curl -sLH 'accept: application/json' "${buildUrl}" | jq -r '.jobsetevals[0]')"
         echo "Evaluating $eval" >&2
         flake="$(curl -sLH 'accept: application/json' "${cfg.instance}/eval/$eval" | jq -r '.flake')"
         echo "New flake: $flake" >&2
         new="$(nix flake metadata "$flake" --json | jq -r '.lastModified')"
         echo $new >&2
         echo "Found latest at: $(date -d @$new) will init it!" >&2

         path="$(curl -sLH 'accept: application/json' ${buildUrl} | jq -r '.buildoutputs.out.path')"

         echo "Building $path" >&2
         nix build --no-link "$path"

        echo "Activating home-manager" >&2
        "$path/activate"

         echo "Setting home-manager profile" >&2
         nix build --no-link --profile "$profile" "$path"
      '';
    };

    systemd.user.services.home-manager-upgrade = {
      description = "Home Manager Upgrade";
      restartIfChanged = false;
      unitConfig.X-StopOnRemoval = false;
      serviceConfig.Type = "oneshot";

      path = with pkgs; [
        config.nix.package.out
        config.programs.ssh.package
        coreutils
        curl
        gitMinimal
        gnutar
        gzip
        jq
        nvd
      ];

      script = let
        buildUrl = "${cfg.instance}/job/${cfg.project}/${cfg.jobset}/${cfg.user.job}/latest";
      in
        (lib.optionalString (cfg.oldFlakeRef != null) ''
          eval="$(curl -sLH 'accept: application/json' "${buildUrl}" | jq -r '.jobsetevals[0]')"
          echo "Evaluating $eval" >&2
          flake="$(curl -sLH 'accept: application/json' "${cfg.instance}/eval/$eval" | jq -r '.flake')"
          echo "New flake: $flake" >&2
          new="$(nix flake metadata "$flake" --json | jq -r '.lastModified')"
          echo $new >&2
          echo "Modified at: $(date -d @$new)" >&2

          echo "Current flake: ${cfg.oldFlakeRef}" >&2
          current="$(nix flake metadata "${cfg.oldFlakeRef}" --json | jq -r '.lastModified')"
          echo "Modified at: $(date -d @$current)" >&2

          if [ "$new" -le "$current" ]; then
            echo "Skipping upgrade, not newer" >&2
            exit 0
          fi
        '')
        + ''
          profile="$HOME/.local/state/nix/profiles/home-manager"
          path="$(curl -sLH 'accept: application/json' ${buildUrl} | jq -r '.buildoutputs.out.path')"

          if [ "$(readlink -f "$profile")" = "$path" ]; then
            echo "Already up to date" >&2
            exit 0
          fi

          echo "Building $path" >&2
          nix build --no-link "$path"

          echo "Comparing changes" >&2
          nvd --color=always diff "$profile" "$path"

          echo "Activating home-manager" >&2
          "$path/activate"

          echo "Setting home-manager profile" >&2
          nix build --no-link --profile "$profile" "$path"
        '';

      startAt = cfg.dates;
      after = ["network-online.target"];
      wants = ["network-online.target"];
    };
  };
}
