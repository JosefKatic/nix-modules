{pkgs, ...}: {
  options.user.desktop.programs.games.communication.discord.enable = lib.mkEnableOption "Enable Discord";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      discord
    ];
  };
}
