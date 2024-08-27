{
  self,
  config,
  lib,
  ...
}: let
  inherit (lib) types mkIf mkEnableOption;
  cfg = config.device.server.homelab;
in {
  options.device.server.homelab = {
    mosquitto = {
      enable = mkEnableOption "Mosquitto";
    };
  };

  config = mkIf cfg.mosquitto.enable {
    networking.firewall.allowedTCPPorts = [1883 9001];

    services.mosquitto = {
      enable = true;
      listeners = [
        {
          users.admin = {
            acl = [
              "readwrite #"
            ];
            hashedPasswordFile = config.sops.secrets.mqtt_server.path;
          };
        }
      ];
    };
    environment.persistence = mkIf config.device.core.storage.enablePersistence {
      "/persist" = {
        directories = ["/var/lib/mosquitto"];
      };
    };

    sops.secrets.mqtt_server = {
      sopsFile = "${self}/secrets/services/mosquitto/secrets.yaml";
      owner = "mosquitto";
    };
  };
}
