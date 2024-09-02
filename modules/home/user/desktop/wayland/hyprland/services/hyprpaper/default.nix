inputs: {
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.user.desktop.wayland.hyprland.services.hyprpaper;
in {
  options.user.desktop.wayland.hyprland.services.hyprpaper.enable = lib.mkEnableOption "Enable Hyprpaper";

  config = lib.mkIf cfg.enable {
    services.hyprpaper = {
      enable = true;
      package = inputs.hyprpaper.packages.${pkgs.system}.default;
      settings = {
        ipc = "off";
        splash = false;
        preload = [
          "${config.theme.wallpaper}"
        ];
        wallpaper = [
          " ,${config.theme.wallpaper}"
        ];
      };
    };
  };
}
