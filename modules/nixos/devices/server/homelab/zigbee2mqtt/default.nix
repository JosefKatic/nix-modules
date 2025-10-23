{
  self,
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) types mkIf mkEnableOption;
  cfg = config.device.server.homelab;
in {
  options.device.server.homelab = {
    zigbee2mqtt = {
      enable = mkEnableOption "Zigbee2mqtt";
    };
  };

  config = mkIf cfg.zigbee2mqtt.enable {
    services.zigbee2mqtt = {
      enable = cfg.zigbee2mqtt.enable;
      settings = {
        homeassistant.enabled = config.device.server.homelab.homeassistant.enable;
        permit_join = false;
        mqtt = {
          base_topic = "zigbee2mqtt";
          server = "mqtt://localhost:1883";
          user = "!${config.sops.templates."zigbee2mqtt-secrets.yaml".path} user";
          password = "!${config.sops.templates."zigbee2mqtt-secrets.yaml".path} password";
        };
        serial = {
          port = "/dev/serial/by-id/usb-dresden_elektronik_ingenieurtechnik_GmbH_ConBee_II_DE2442673-if00";
          adapter = "deconz";
        };
        frontend = true;
      };
    };

    networking.firewall.allowedTCPPorts = [8080];

    sops.templates."zigbee2mqtt-secrets.yaml" = {
      owner = "zigbee2mqtt";
      content = ''
        user: admin
        password: ${config.sops.placeholder.mqtt_client}
      '';
    };

    sops.secrets.mqtt_client = {
      sopsFile = "${self}/secrets/services/mosquitto/secrets.yaml";
      owner = "zigbee2mqtt";
    };
    environment.persistence = mkIf config.device.core.storage.enablePersistence {
      "/persist" = {
        directories = ["/var/lib/zigbee2mqtt"];
      };
    };
  };
}
