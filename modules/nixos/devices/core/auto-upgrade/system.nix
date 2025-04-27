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
    company.autoUpgrade.system = {
      enable = lib.mkEnableOption "Periodic hydra-based auto upgrade";
      job = lib.mkOption {
        type = lib.types.str;
        default = "hosts.${config.networking.hostName}";
      };
    };
  };

  config = lib.mkIf cfg.system.enable {
    assertions = [
      {
        assertion = cfg.system.enable -> !config.system.autoUpgrade.enable;
        message = ''
          hydraAutoUpgrade and autoUpgrade are mutually exclusive.
        '';
      }
    ];

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
        buildUrl = "${cfg.instance}/job/${cfg.project}/${cfg.jobset}/${cfg.system.job}/latest";
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
