{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) types mkIf mkEnableOption;
  cfg = config.device.server.homelab;
in {
  options.device.server.homelab = {
    homeassistant = {
      enable = mkEnableOption "Home Assistant";
    };
  };

  config = mkIf cfg.homeassistant.enable {
    environment.persistence = lib.mkIf config.device.core.storage.enablePersistence {
      "/persist" = {
        directories = [
          "/var/lib/containers"
        ];
      };
    };
    services = {
      # nginx.virtualHosts."hass.joka00.dev" = {
      #   extraConfig = ''
      #     allow 10.34.70.0/23;
      #     allow 100.64.0.0/10;
      #     deny all;
      #   '';
      #   forceSSL = true;
      #   useACMEHost = "joka00.dev";
      #   locations."/" = {
      #     proxyPass = "http://[::1]:${toString config.services.home-assistant.config.http.server_port}";
      #     proxyWebsockets = true;
      #   };
      # };
    };
    virtualisation.oci-containers = {
      backend = "podman";
      containers.homeassistant = {
        volumes = ["home-assistant:/config"];
        environment.TZ = "Europe/Berlin";
        image = "ghcr.io/home-assistant/home-assistant:stable";
        extraOptions = [
          "--network=host"
          "--device=/dev/ttyACM0:/dev/ttyACM0"
        ];
      };
    };
    networking.firewall.allowedTCPPorts = [8123 21063 21064];
    networking.firewall.allowedUDPPorts = [5353 21063 21064];
  };
}
