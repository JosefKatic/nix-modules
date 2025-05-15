{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.user.desktop.programs.productivity.proton.mail;
in {
  options.user.desktop.programs.media.music.youtube-music = {
    enable = lib.mkEnableOption "Enable YouTube Music";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.youtube-music
    ];
  };
}
