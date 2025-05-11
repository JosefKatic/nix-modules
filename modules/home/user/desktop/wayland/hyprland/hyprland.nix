inputs: {
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.user.desktop.wayland.hyprland;
in {
  options.user.desktop.wayland.hyprland.enable = lib.mkEnableOption "Enable Hyprland";
  # enable hyprland

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      package = pkgs.hyprland;
      portalPackage = pkgs.xdg-desktop-portal-hyprland;
      # make sure to also set the portal package, so that they are in sync
      systemd = {
        variables = ["--all"];
        extraCommands = [
          "systemctl --user stop graphical-session.target"
          "systemctl --user start hyprland-session.target"
        ];
      };
    };
    user.desktop.wayland.hyprland.services.anyrun.enable = true;
    user.desktop.wayland.hyprland.services.hypridle.enable = true;
    user.desktop.wayland.hyprland.services.hyprlock.enable = true;
    user.desktop.wayland.hyprland.services.hyprpaper.enable = true;
    user.desktop.wayland.hyprland.services.hyprsunset.enable = true;
  };
}
