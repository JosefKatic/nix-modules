{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.user.desktop.services.polkit_agent;
in {
  options.user.desktop.services.polkit_agent = {
    enable = lib.mkEnableOption "Enable Polkit Agent";
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.hyprpolkitagent-1 = {
      Unit.Description = "hyprpolkitagent-1";

      Install = {
        WantedBy = ["graphical-session.target"];
        Wants = ["graphical-session.target"];
        After = ["graphical-session.target"];
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };
}
