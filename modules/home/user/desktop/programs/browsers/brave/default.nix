{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.user.desktop.programs.browsers;
in {
  options.user.desktop.programs.browsers.brave.enable =
    lib.mkEnableOption "Enable Brave browser";

  config = lib.mkIf cfg.brave.enable {home.packages = [pkgs.brave];};
}
