{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.user.desktop.programs.media.video.obs;
in {
  options = {
    user.desktop.programs.media.video = {
      obs = {
        enable = lib.mkEnableOption "Enable obs-studio";
        package = lib.mkOption {
          type = lib.types.package;
          default = pkgs.obs-studio;
          description = "OBS package";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.obs-studio = {
      enable = cfg.enable;
      package = pkgs.obs-studio;
    };
  };
}
