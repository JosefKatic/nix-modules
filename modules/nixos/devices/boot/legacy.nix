{
  config,
  lib,
  ...
}: let
  cfg = config.device;
in {
  config = lib.mkIf (cfg.boot.uefi.enable == false) {
    boot = {
      initrd = {
        systemd.enable = true;
        supportedFilesystems = ["btrfs"];
      };
      loader = {
        grub = {
          enable = lib.mkDefault true;
          device = lib.mkDefault "/dev/vda";
        };
      };
    };
    fileSystems."/boot" = {
      device = lib.mkDefault cfg.core.storage.systemDrive.path;
      fsType = "btrfs";
      options = ["subvol=@boot"];
    };
  };
}
