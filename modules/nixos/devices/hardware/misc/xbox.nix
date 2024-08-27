{
  lib,
  config,
  ...
}: let
  cfg = config.device.hardware.misc;
in {
  options.device.hardware.misc.xbox.enable =
    lib.mkEnableOption "Whether to enable Xbox accessories";
  config = lib.mkIf cfg.xbox.enable {hardware.xone.enable = true;};
}
