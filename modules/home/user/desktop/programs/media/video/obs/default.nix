{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.user.desktop.programs.editors.obs-studio;
in {
  options = {
    user.desktop.programs.video = {
      obs-studio = {
        enable = lib.mkEnableOption "Enable obs-studio";
        package = lib.mkOption {
          type = lib.types.package;
          default = pkgs.obs-studio;
          description = "OBS package";
        };
        enableVirtualCamera = lib.mkEnableOption "Enable enableVirtualCamera";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.obs-studio = {
      enable = cfg.enable;
      package = pkgs.obs-studio;
      enableVirtualCamera = cfg.enableVirtualCamera;
    };
  };
}
