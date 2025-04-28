{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.user.desktop.services.polkit_agent;
in {
  options.user.desktop.services.polkit_agent = {
    enable = lib.mkEnableOption "Enable Polkit Agent";
  };

  config = lib.mkIf cfg.enable {
    services.hyprpolkitagent.enable = true;
  };
}
