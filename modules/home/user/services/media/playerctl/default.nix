{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.user.services.media.playerctl;
in {
  options.user.services.media.playerctl = {
    enable = lib.mkEnableOption "Enable playerctl";
  };
  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.playerctl];
    services.playerctld.enable = true;
  };
}
