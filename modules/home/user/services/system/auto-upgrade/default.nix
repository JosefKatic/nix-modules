{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) types mkIf mkEnableOption mkOption;
  cfg = config.user.services.system.autoUpgrade;
in {
  options.user.services.system.autoUpgrade = {
    enable = mkEnableOption "Enable auto-upgrade";
    flake = mkOption {
      type = types.str;
      default = "github:JosefKatic/nix-config";
      description = "Flake to upgrade to";
    };
    dates = mkOption {
      type = types.str;
      default = "hourly";
      example = "daily";
      description = ''
        How often or when upgrade occurs. For most desktop and server systems
        a sufficient upgrade frequency is once a day.

        The format is described in
        {manpage}`systemd.time(7)`.
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.home-manager-upgrade = {
      description = "Home-manager Upgrade";
      restartIfChanged = false;
      unitConfig.X-StopOnRemoval = false;
      serviceConfig.Type = "oneshot";
      path = with pkgs; [
        coreutils
        config.nix.package.out
        home-manager
      ];
      script = let
      in ''
        echo "Upgrade Home Manager"
        ${pkgs.home-manager}/bin/home-manager switch --flake ${cfg.flake}
      '';
      startAt = cfg.dates;
      after = ["network-online.target"];
      wants = ["network-online.target"];
    };
  };
}
