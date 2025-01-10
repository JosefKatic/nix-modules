{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.device.hardware.gpu;
in {
  options.device.hardware.gpu.nvidia = {
    enable = lib.mkEnableOption "Enable Nvidia GPU";
  };
  config = lib.mkIf cfg.nvidia.enable {
    services.pulseaudio.support32Bit = true;
    boot.kernelParams = ["nvidia.NVreg_PreserveVideoMemoryAllocations=1"];
    services.xserver = {videoDrivers = ["nvidia"];};
    hardware = {
      graphics = {
        enable32Bit = true;
        extraPackages = with pkgs; [
          vaapiVdpau
          libvdpau-va-gl
          nvidia-vaapi-driver
        ];
      };
      nvidia = {
        powerManagement.enable = true;
        modesetting.enable = true;
        open = true;
        nvidiaSettings = true;
        package = pkgs.linuxKernel.packages.${config.device.core.kernel}.nvidia_x11;
      };
    };
  };
}
