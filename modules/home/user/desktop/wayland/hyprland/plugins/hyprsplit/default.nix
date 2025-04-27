{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.user.desktop.wayland.hyprland.plugins.hyprsplit;
in {
  options.user.desktop.wayland.hyprland.plugins.hyprsplit = {
    enable = lib.mkEnableOption "Enable HyprSplit";
    numberOfWorkspaces = lib.mkOption {
      type = lib.types.int;
      default = 10;
      description = "Number of workspaces";
    };
  };

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      plugins = [
        pkgs.hyprlandPlugins.hyprsplit
      ];
      settings = {
        plugin = {
          hyprsplit = {
            num_workspaces = cfg.numberOfWorkspaces;
            persistent_workspaces = true;
          };
        };
      };
    };
  };
}
