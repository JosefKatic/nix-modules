{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.user.desktop.programs.browsers;
in {
  options.user.desktop.programs.browsers.chromium.enable =
    lib.mkEnableOption "Enable Chromium browser";

  config = lib.mkIf cfg.chromium.enable {
    programs.chromium = {
      enable = true;
      package = pkgs.chromium;
    };
  };
}
