{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.device.utils;
in {
  options.device.utils.opendrop.enable = lib.mkEnableOption "Enable OpenDrop";

  config = lib.mkIf cfg.opendrop.enable {
    environment.systemPackages = [
      pkgs.opendrop
    ];
  };
}
