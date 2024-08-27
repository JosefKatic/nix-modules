{
  config,
  lib,
  ...
}: let
  cfg = config.user.desktop.wayland.hyprland;
in {
  options.user.desktop.wayland.hyprland.enable = lib.mkEnableOption "Enable Hyprland";
  # enable hyprland

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;

      systemd = {
        variables = ["--all"];
        extraCommands = [
          "systemctl --user stop graphical-session.target"
          "systemctl --user start hyprland-session.target"
        ];
      };
    };
  };
}
