{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.user.desktop.programs.games.communication.teamspeak;
in {
  options.user.desktop.programs.games.communication.teamspeak.enable = lib.mkEnableOption "Enable TeamSpeak";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      teamspeak6-client
    ];
  };
}
