{
  config,
  inputs,
  pkgs,
  lib,
  ...
}: let
  cfg = config.device.utils;
  # Only enable auto upgrade if current config came from a clean tree
  # This avoids accidental auto-upgrades when working locally.
  isClean = inputs.self ? rev;
  inherit (config.networking) hostName;
in {
  options.device.utils.autoUpgrade = {
    enable = lib.mkEnableOption "Enable auto-upgrade";
  };

  config = lib.mkIf cfg.autoUpgrade.enable {
    system.autoUpgrade = {
      enable = isClean;
      dates = "hourly";
      allowReboot = true;
      rebootWindow = {
        lower = "17:00";
        upper = "03:00";
      };
      flags = [
        "--refresh"
      ];
      flake = "git://joka00.dev/nix-config?ref=release-${hostName}";
    };
    # Only run if current config (self) is older than the new one.
    systemd.services.nixos-upgrade = lib.mkIf config.device.utils.autoUpgrade.enable {
      serviceConfig.ExecCondition = lib.getExe (
        pkgs.writeShellScriptBin "check-date" ''
          lastModified() {
            nix flake metadata "$1" --refresh --json | ${lib.getExe pkgs.jq} '.lastModified'
          }
          test "$(lastModified "${config.system.autoUpgrade.flake}")"  -gt "$(lastModified "self")"
        ''
      );
    };
  };
}
