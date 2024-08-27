{
  config,
  lib,
  ...
}: let
  cfg = config.device;
in {
  options.device.utils.kdeconnect.enable = lib.mkEnableOption "Enable KDE Connect";

  config = {programs = {kdeconnect.enable = cfg.utils.kdeconnect.enable;};};
}
