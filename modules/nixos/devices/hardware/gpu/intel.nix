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
