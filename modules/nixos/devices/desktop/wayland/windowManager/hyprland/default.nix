{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.device.desktop.wayland.windowManager.hyprland;
in {
  options.device.desktop.wayland.windowManager.hyprland = {
    enable = lib.mkEnableOption "Enable Hyprland";
  };

  config = lib.mkIf cfg.enable {
    qt.enable = true;
    environment.systemPackages = with pkgs; [kdePackages.qtdeclarative];
    programs.hyprland = {
      enable = true;
      package = pkgs.hyprland;
      portalPackage = pkgs.xdg-desktop-portal-hyprland;
    };
    security.pam.services.hyprlock.text = "auth include login";
  };
}
