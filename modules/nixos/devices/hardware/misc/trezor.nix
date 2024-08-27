{
  lib,
  config,
  ...
}: let
  cfg = config.device.hardware.misc;
in {
  options.device.hardware.misc.trezor.enable =
    lib.mkEnableOption "Whether to enable Trezor support";
  config =
    lib.mkIf cfg.trezor.enable {services.trezord.enable = cfg.trezor.enable;};
}
