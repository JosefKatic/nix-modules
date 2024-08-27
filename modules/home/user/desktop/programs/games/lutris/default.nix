{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.user.desktop.programs.games.lutris;
in {
  options.user.desktop.programs.games.lutris.enable = lib.mkEnableOption "Enable Minecraft";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      (lutris.override
        {
          extraPkgs = p: [
            p.wineWowPackages.staging
            p.pixman
            p.libjpeg
            p.zenity
          ];
        })
      winetricks
    ];
  };
}
