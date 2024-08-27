{
  config,
  lib,
  ...
}: let
  cfg = config.device.hardware;
in {
  options.device.hardware.disks.ssd = {
    enable = lib.mkEnableOption "Enable ssd modules";
  };

  config = lib.mkIf cfg.disks.ssd.enable {
    services.fstrim.enable = true;
  };
}
