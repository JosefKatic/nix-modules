# This file was copied from misterio77 and it's avaliable at:
# https://raw.githubusercontent.com/Misterio77/nix-config/74311ba3ddab44e18f45582b56d92fde274bdc32/modules/nixos/hydra-auto-upgrade.nix
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
    company.autoUpgrade = {
      enable = lib.mkEnableOption "periodic hydra-based auto upgrade";
      operation = lib.mkOption {
        type = lib.types.enum ["switch" "boot"];
        default = "switch";
      };
      dates = lib.mkOption {
        type = lib.types.str;
        default = "hourly";
        example = "daily";
      };
      instance = lib.mkOption {
        type = lib.types.str;
        default = "https://hydra.joka00.dev";
      };
      flake = lib.mkOption {
        type = lib.types.str;
        default = "github:JosefKatic/nix-config";
        description = "Link to flake";
      };
      project = lib.mkOption {
        type = lib.types.str;
        default = "nix-config";
      };
      jobset = lib.mkOption {
        type = lib.types.str;
        default = "main";
      };
      job = lib.mkOption {
        type = lib.types.str;
        default = "hosts.${config.networking.hostName}";
      };
      oldFlakeRef = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = "self";
        description = ''
          Current system's flake reference

          If non-null, the service will only upgrade if the new config is newer
          than this one's.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.enable -> !config.system.autoUpgrade.enable;
        message = ''
          hydraAutoUpgrade and autoUpgrade are mutually exclusive.
        '';
      }
    ];

    systemd.user.services.home-manager-setup = {
      wantedBy = ["graphical-session.target"];
      wants = ["nix-daemon.socket" "network-online.target"];
      path = ["/run/current-system/sw" pkgs.nix pkgs.git pkgs.coreutils pkgs.home-manager];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = false;
      };
      script = ''
        ${pkgs.home-manager}/bin/home-manager switch -b backup --flake ${config.company.autoUpgrade.flake}
      '';
    };

    systemd.services.nixos-upgrade = {
      description = "NixOS Upgrade";
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
        buildUrl = "${cfg.instance}/job/${cfg.project}/${cfg.jobset}/${cfg.job}/latest";
      in
        (lib.optionalString (cfg.oldFlakeRef != null) ''
          eval="$(curl -sLH 'accept: application/json' "${buildUrl}" | jq -r '.jobsetevals[0]')"
          flake="$(curl -sLH 'accept: application/json' "${cfg.instance}/eval/$eval" | jq -r '.flake')"          echo "New flake: $flake" >&2
          new="$(nix flake metadata "$flake" --json | jq -r '.lastModified')"
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
          profile="/nix/var/nix/profiles/system"
          path="$(curl -sLH 'accept: application/json' ${buildUrl} | jq -r '.buildoutputs.out.path')"

          if [ "$(readlink -f "$profile")" = "$path" ]; then
            echo "Already up to date" >&2
            exit 0
          fi

          echo "Building $path" >&2
          nix build --no-link "$path"

          echo "Comparing changes" >&2
          nvd --color=always diff "$profile" "$path"

          echo "Activating configuration" >&2
          "$path/bin/switch-to-configuration" test

          echo "Setting profile" >&2
          nix build --no-link --profile "$profile" "$path"

          echo "Adding to bootloader" >&2
          "$path/bin/switch-to-configuration" boot
        '';

      startAt = cfg.dates;
      after = ["network-online.target"];
      wants = ["network-online.target"];
    };
  };
}
