{pkgs, ...}: {
  options.user.desktop.programs.games.communication.teamspeak.enable = lib.mkEnableOption "Enable TeamSpeak";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      teamspeak_client
    ];
  };
}
