{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.user.desktop.wayland.hyprland.services.hyprpaper;
in {
  options.user.desktop.wayland.hyprland.services.hyprsunset.enable = lib.mkEnableOption "Enable Hyprsunset - blue light filter";
  config = lib.mkIf cfg.enable {
    services.hyprsunset = {
      enable = true;
      transitions = {
        sunrise = {
          calendar = "*-*-* 07:00:00";
          requests = [
            ["idenity"]
          ];
        };
        sunset = {
          calendar = "*-*-* 22:00:00";
          requests = [
            ["temperature" "3000"]
          ];
        };
      };
    };
  };
}
