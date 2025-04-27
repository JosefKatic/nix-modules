inputs: {
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.device.desktop.wayland.windowManager;
in {
  options.device.desktop.wayland.windowManager = {
    hyprland = {enable = lib.mkEnableOption "Enable Hyprland";};
    sway = {enable = lib.mkEnableOption "Enable Sway";};
  };

  config = {
    programs.hyprland = {
      enable = cfg.hyprland.enable;
      package = pkgs.hyprland;
      portalPackage = pkgs.xdg-desktop-portal-hyprland;
    };
    # security.pam.services.hyprlock.text = lib.optionals (cfg.hyprland.enable) "auth include login";
    programs.sway.enable = cfg.sway.enable;
  };
}
