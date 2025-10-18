{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.device;
  hasOptinPersistence = config.environment.persistence ? "/persist";
in {
  options.device.boot.uefi = {
    enable = lib.mkEnableOption "Whether to enable UEFI booting";
    secureboot = lib.mkEnableOption "Whether to enable secureboot";
  };

  config = lib.mkIf cfg.boot.uefi.enable {
    environment.systemPackages = with pkgs; [
      sbctl
    ];
    boot = {
      bootspec.enable = true;
      initrd = {
        systemd.enable = true;
        supportedFilesystems = ["btrfs"];
      };
      loader = {
        # Disable systemd-boot if lanzaboote is enabled
        systemd-boot = {enable = !cfg.boot.uefi.secureboot;};
        efi = {
          canTouchEfiVariables = true;
          # EFI partition is mounted to /efi instead of /boot/efi
          efiSysMountPoint = "/efi";
        };
      };
      lanzaboote = {
        enable = cfg.boot.uefi.secureboot;
        pkiBundle = "${lib.optionalString hasOptinPersistence "/persist"}/var/lib/sbctl";
      };
    };
    fileSystems."/efi" = {
      device = lib.mkDefault "/dev/disk/by-label/EFI";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };

    environment.persistence = lib.mkIf (cfg.core.storage.enablePersistence && cfg.boot.uefi.secureboot) {
      "/persist" = {
        directories = ["/var/lib/sbctl"];
      };
    };
  };
}
