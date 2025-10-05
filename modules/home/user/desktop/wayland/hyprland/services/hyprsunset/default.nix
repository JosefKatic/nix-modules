{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.user.desktop.wayland.hyprland.services.hyprsunset;
in {
  options.user.desktop.wayland.hyprland.services.hyprsunset.enable = lib.mkEnableOption "Enable Hyprsunset - blue light filter";
  config = lib.mkIf cfg.enable {
    services.hyprsunset = {
      enable = true;
      settings = {
        profile = [
          {
            time = "7:30";
            identity = true;
          }
          {
            time = "22:00";
            temperature = 3000;
            gamma = 0.8;
          }
        ];
      };
    };
  };
}
