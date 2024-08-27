{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.user.desktop.programs.media.mpv;
in {
  options.user.desktop.programs.media.mpv = {
    enable = pkgs.lib.mkEnableOption "Enable MPV media player";
  };

  config = lib.mkIf cfg.enable {
    programs.mpv = {
      enable = true;
      defaultProfiles = ["gpu-hq"];
      scripts = [pkgs.mpvScripts.mpris];
    };
  };
}
