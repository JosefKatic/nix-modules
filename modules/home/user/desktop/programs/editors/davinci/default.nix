{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.user.desktop.programs.editors.davinci;
in {
  options = {
    user.desktop.programs.editors.davinci = {
      enable = lib.mkEnableOption "Enable DaVinci Resolve";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.davinci-resolve];
  };
}
