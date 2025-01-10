{
  config,
  lib,
  pkgs,
  ...
}: {
  options.device.hardware.gpu.amd = {
    enable = lib.mkEnableOption "Enable AMD GPU support";
  };
  config = lib.mkIf config.device.hardware.gpu.amd.enable {
    services.xserver.videoDrivers = lib.mkDefault ["amdgpu"];
    hardware.graphics.enable32Bit = true;
    services.pulseaudio.support32Bit = true;
    boot.initrd.kernelModules = ["amdgpu"];
    hardware.graphics.extraPackages =
      if pkgs ? rocmPackages.clr
      then with pkgs.rocmPackages; [clr clr.icd]
      else with pkgs; [rocm-opencl-icd rocm-opencl-runtime];
  };
}
