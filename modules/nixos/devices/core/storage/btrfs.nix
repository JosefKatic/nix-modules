{
  config,
  lib,
  options,
  pkgs,
  ...
}: let
  cfg = config.device;

  otherDrivesOpts = {
    name,
    config,
    ...
  }: {
    options = {
      path = lib.mkOption {
        type = lib.types.path;
        description = "The path to the drive.";
      };
    };
  };
in {
  options.device.core.storage = {
    systemDrive = {
      name = lib.mkOption {
        type = lib.types.str;
        default = "system";
        description = "The name of the system drive.";
      };
      path = lib.mkOption {
        type = lib.types.path;
        default = "/dev/disk/by-label/system";
        description = "The path to the system drive.";
      };
    };
    otherDrives = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule [otherDrivesOpts]);
      default = {};
      description = "The names of the other drives.";
    };
  };
  config = {
    fileSystems = {
      "/" = {
        device = "/dev/disk/by-label/system";
        fsType = "btrfs";
        options = ["subvol=@root" "compress=zstd" "noatime"];
      };

      "/home" = {
        device = "/dev/disk/by-label/system";
        fsType = "btrfs";
        options = ["subvol=@home" "compress=zstd" "noatime"];
      };

      "/nix" = {
        device = "/dev/disk/by-label/system";
        fsType = "btrfs";
        options = ["subvol=@nix" "compress=zstd" "noatime"];
      };

      "/persist" = {
        device = "/dev/disk/by-label/system";
        fsType = "btrfs";
        options = ["subvol=@persist" "compress=zstd" "noatime"];
        neededForBoot = true;
      };

      "/swap" = {
        device = "/dev/disk/by-label/system";
        fsType = "btrfs";
        options = ["subvol=@swap" "compress=zstd" "noatime"];
      };
    };
  };
}
