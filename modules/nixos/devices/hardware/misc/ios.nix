{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.device.hardware.misc;
in {
  options.device.hardware.misc.ios.enable = lib.mkEnableOption "Enable iOS device support";

  config = lib.mkIf cfg.ios.enable {
    services.usbmuxd = {
      enable = true;
      package = pkgs.usbmuxd2;
    };

    environment.systemPackages = with pkgs; [
      libimobiledevice
      ifuse
    ];
  };
}
