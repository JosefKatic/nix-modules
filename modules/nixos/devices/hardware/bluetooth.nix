{
  config,
  lib,
  options,
  pkgs,
  ...
}: let
  cfg = config.device.hardware;
in {
  options.device.hardware.bluetooth = {
    enable = lib.mkEnableOption "Enable Bluetooth support";
    enableManager = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Bluetooth manager";
    };
  };

  config = lib.mkIf cfg.bluetooth.enable {
    hardware.bluetooth = {
      enable = true;
      settings = {General = {Experimental = true;};};
    };
    services.blueman.enable = cfg.bluetooth.enableManager;

    # https://github.com/NixOS/nixpkgs/issues/114222
    systemd.user.services.telephony_client.enable = false;

    environment.persistence = lib.mkIf config.device.core.storage.enablePersistence {
      "/persist" = {
        directories = ["/var/lib/bluetooth"];
      };
    };
  };
}
