{
  config,
  lib,
  pkgs,
  ...
}: {
  options.user.desktop.services.kdeconnect = {
    enable = lib.mkEnableOption "Enable KDEConnect";
  };

  config = lib.mkIf config.user.desktop.services.kdeconnect.enable {
    systemd.user.services.kdeconnect = {
      Unit.Description = "KDEConnect Service";
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.kdePackages.kdeconnect-kde}/bin/kdeconnect-indicator";
        TimeoutStopSec = 5;
      };
      Install.WantedBy = ["graphical-session.target"];
    };
  };
}
