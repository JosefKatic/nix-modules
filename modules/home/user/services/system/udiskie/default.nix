{
  config,
  lib,
  ...
}: let
  cfg = config.user.services.system.udiskie;
in {
  options.user.services.system.udiskie = {
    enable = lib.mkEnableOption "Enable udiskie";
  };
  config = lib.mkIf cfg.enable {
    services.udiskie = {
      enable = true;
    };
  };
}
