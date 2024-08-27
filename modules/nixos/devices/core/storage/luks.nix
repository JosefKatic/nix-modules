{
  config,
  lib,
  ...
}: let
  cfg = config.device.core.storage;
in {
  options.device.core.storage.systemDrive.encrypted = {
    enable = lib.mkEnableOption "Encrypt system drive";
    path = lib.mkOption {
      type = lib.types.str;
      default = "/dev/disk/by-partlabel/cryptsystem";
      description = ''
        The path to the system drive.
      '';
    };
  };

  config = lib.mkIf cfg.systemDrive.encrypted.enable {
    boot.initrd.luks.devices = {
      ${cfg.systemDrive.name}.device =
        cfg.systemDrive.encrypted.path;
    };
  };
}
