{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.user.desktop.programs.media.music.youtube-music;
  cfgHyprland = config.user.desktop.wayland.hyprland;
in {
  options.user.desktop.programs.media.music.youtube-music = {
    enable = lib.mkEnableOption "Enable YouTube Music";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.youtube-music
    ];

    wayland.windowManager.hyprland.settings = lib.mkIf cfgHyprland.enable {
      bind = [
        # YouTube Music
        "ALT, M, togglespecialworkspace, ytm"
      ];
      exec-once = [
        "[workspace special:ytm silent] youtube-music"
      ];
    };
  };
}
