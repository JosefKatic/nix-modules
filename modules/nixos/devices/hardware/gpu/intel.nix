{
  config,
  lib,
  pkgs,
  ...
}: {
  options.device.hardware.gpu.intel = {
    enable = lib.mkEnableOption "Enable Intel GPU support";
  };
  config = lib.mkIf config.device.hardware.gpu.intel.enable {
    hardware.graphics.enable32Bit = true;
    services.pulseaudio.support32Bit = true;
    boot.initrd.kernelModules = ["i915"];
    environment.variables = {
      VDPAU_DRIVER =
        lib.mkIf config.hardware.graphics.enable (lib.mkDefault "va_gl");
    };

    hardware.graphics.extraPackages = with pkgs; [
      (
        if (lib.versionOlder (lib.versions.majorMinor lib.version) "23.11")
        then vaapiIntel
        else intel-vaapi-driver
      )
      libvdpau-va-gl
      intel-media-driver
    ];
  };
}
