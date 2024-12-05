{
  self,
  config,
  lib,
  ...
}: {
  imports = [
    ./blocky
    ./homeassistant
    ./mosquitto
    ./zigbee2mqtt
  ];

  options.device.server.homelab = {
    enable = lib.mkEnableOption "Enable homelab services";
  };

  config = lib.mkIf config.device.server.homelab.enable {
    sops.secrets.acme-secrets = {
      sopsFile = "${self}/secrets/services/homelab/secrets.yaml";
    };
  };
}
