{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.device.desktop.wayland.windowManager.sway;
in {
  options.device.desktop.wayland.windowManager.sway = {
    enable = lib.mkEnableOption "Enable Sway";
  };

  config = lib.mkIf cfg.enable {
    programs.sway.enable = true;
  };
}
