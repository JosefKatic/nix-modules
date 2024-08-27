{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.device.core.storage;
in {
  options.device.core.storage.swapFile = {
    enable = lib.mkEnableOption "Enables the creation of a swap file";
    path = lib.mkOption {
      type = lib.types.path;
      default = "/swap/swapfile";
      description = "The path to the swap file.";
    };
    size = lib.mkOption {
      type = lib.types.int;
      default = 2;
      description = "The size of the swap file in GiB.";
    };
  };

  config = lib.mkIf cfg.swapFile.enable {
    swapDevices = [
      {
        device = cfg.swapFile.path;
        size = cfg.swapFile.size * 1024;
      }
    ];

    systemd.services = {
      create-swapfile = {
        serviceConfig.Type = "oneshot";
        wantedBy = ["swap-swapfile.swap"];
        script = ''
          swapfile="/swap/swapfile"
            if [[ -f "$swapfile" ]]; then
              echo "Swap file $swapfile already exists, taking no action"
            else
              echo "Setting up swap file $swapfile"
              ${pkgs.coreutils}/bin/truncate -s 0 "$swapfile"
              ${pkgs.e2fsprogs}/bin/chattr +C "$swapfile"
            fi
        '';
      };
    };
  };
}
