{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.user.desktop.programs.games.minecraft;
in {
  options.user.desktop.programs.games.minecraft.enable = lib.mkEnableOption "Enable Minecraft";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      prismlauncher
      lunar-client
    ];
  };
}
