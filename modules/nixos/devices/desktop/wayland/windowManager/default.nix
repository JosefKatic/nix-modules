inputs: {
  config,
  lib,
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
      package = inputs.hyprland.packages.${pkgs.system}.hyprland;
      # make sure to also set the portal package, so that they are in sync
      portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
    };
    # security.pam.services.hyprlock.text = lib.optionals (cfg.hyprland.enable) "auth include login";
    programs.sway.enable = cfg.sway.enable;
  };
}
