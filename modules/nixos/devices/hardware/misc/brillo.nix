{
  config,
  lib,
  ...
}: {
  config = lib.mkIf (config.device.type == "laptop" || config.device.type == "desktop") {
    hardware.brillo.enable = true;
  };
}
