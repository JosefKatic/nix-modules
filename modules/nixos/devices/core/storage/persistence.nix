{
  config,
  lib,
  ...
}: let
  cfg = config.device.core.storage;
  wipeScript = ''
    mkdir /tmp -p
    MNTPOINT=$(mktemp -d)
    (
      mount -t btrfs -o subvol=/ ${cfg.systemDrive.path} "$MNTPOINT"
      trap 'umount "$MNTPOINT"' EXIT

      echo "Creating needed directories"
      mkdir -p "$MNTPOINT"/persist/var/{log,lib/{nixos,systemd}}

      echo "Cleaning root subvolume"
      btrfs subvolume list -o "$MNTPOINT/@root" | cut -f9 -d ' ' |
      while read -r subvolume; do
        btrfs subvolume delete "$MNTPOINT/$subvolume"
      done && btrfs subvolume delete "$MNTPOINT/@root"

      echo "Restoring blank subvolume"
      btrfs subvolume snapshot "$MNTPOINT/@root-blank" "$MNTPOINT/@root"
    )
  '';
  phase1Systemd = config.boot.initrd.systemd.enable;
in {
  options.device.core.storage.enablePersistence =
    lib.mkEnableOption "Whether to enable persistence of root";

  config = lib.mkIf cfg.enablePersistence {
    boot.initrd = {
      supportedFilesystems = ["btrfs" "ntfs"];
      postDeviceCommands = lib.mkIf (!phase1Systemd) (lib.mkBefore wipeScript);
      systemd.services.restore-root = lib.mkIf phase1Systemd {
        description = "Rollback btrfs rootfs";
        wantedBy = ["initrd.target"];
        requires = ["dev-disk-by\\x2dlabel-system.device"];
        after = [
          "dev-disk-by\\x2dlabel-system.device"
          "systemd-cryptsetup@system.service"
        ];
        before = ["sysroot.mount"];
        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";
        script = wipeScript;
      };
    };

    environment.persistence = {
      "/persist" = {
        directories = [
          "/var/log"
          "/var/lib/nixos"
          "/var/lib/systemd"
          "/var/lib/docker"
          "/var/lib/sops-nix"
          "/srv"
          "/etc/nixos"
          "/etc/NetworkManager/system-connections"
        ];
      };
    };
    programs.fuse.userAllowOther = true;
    system.activationScripts.persistent-dirs.text = let
      mkHomePersist = user:
        lib.optionalString user.createHome ''
          mkdir -p /persist/${user.home}
          chown ${user.name}:${user.group} /persist/${user.home}
          chmod ${user.homeMode} /persist/${user.home}
        '';
      users = lib.attrValues config.users.users;
    in
      lib.concatLines (map mkHomePersist users);
  };
}
