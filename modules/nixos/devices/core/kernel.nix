{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.device.core;
in {
  options = {
    device.core.kernel = lib.mkOption {
      default = "linux_zen";
      type = lib.types.str;
    };
  };

  config = {
    boot = {
      kernelPackages = pkgs.linuxKernel.packages.${config.device.core.kernel};
      extraModulePackages = with config.boot.kernelPackages; [ddcci-driver];
      extraModprobeConfig = lib.mkIf config.device.virtualized "options kvm nested=1";
    };
    services.fwupd.enable = true;
  };
}
