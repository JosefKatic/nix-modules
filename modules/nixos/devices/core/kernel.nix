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
      initrd = {
        availableKernelModules =
          lib.optionals config.device.virtualized ["ata_piix" "uhci_hcd" "virtio_pci" "sr_mod" "virtio_blk"]
          ++ lib.optionals (config.device.virtualized != false) ["nvme" "xhci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc"];
      };
      extraModprobeConfig = lib.mkIf config.device.virtualized "options kvm nested=1";
    };
    services.fwupd.enable = true;
    systemd.services.hv-kvp.unitConfig.ConditionPathExists = lib.mkIf config.device.virtualized ["/dev/vmbus/hv_kvp"];
    virtualisation.hypervGuest.enable = lib.mkIf config.device.virtualized true;
  };
}
