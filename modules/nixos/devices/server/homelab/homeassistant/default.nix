{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) types mkIf mkEnableOption;
  cfg = config.device.server.homelab;

  scripts = import ./scripts.nix;
  # homeassistantPackages = import ./pkgs {inherit pkgs;};
in {
  options.device.server.homelab = {
    homeassistant = {
      enable = mkEnableOption "Home Assistant";
    };
  };

  config = mkIf cfg.homeassistant.enable {
    # environment.systemPackages = [pkgs.home-assistant];
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
      home-assistant = let
      in {
        enable = cfg.homeassistant.enable;
        package = pkgs.home-assistant;
        extraPackages = python3Packages:
          with python3Packages; [
            gtts
            pyatv
          ];
        extraComponents = [
          # Components required to complete the onboarding
          "cloud"
          "broadlink"
          "default_config"
          "esphome"
          "met"
          "mqtt"
          "mobile_app"
          "homekit"
          "homekit_controller"
          "radio_browser"
          "network"
          "tailscale"
          "tuya"
          "samsungtv"
          "system_health"
          "system_log"
          "update"
          "websocket_api"
          "upnp"
          "zeroconf"
          "zha"
        ];
        customComponents = [
          pkgs.home-assistant-custom-components.adaptive_lighting
          pkgs.home-assistant-custom-components.localtuya
        ];
        customLovelaceModules = with pkgs; [
          home-assistant-custom-lovelace-modules.card-mod
          home-assistant-custom-lovelace-modules.button-card
          home-assistant-custom-lovelace-modules.mini-graph-card
          home-assistant-custom-lovelace-modules.mushroom
        ];
        config = {
          default_config = {};
          config = {};
          mobile_app = {};
          cloud = {};
          network = {};
          zeroconf = {};
          system_health = {};
          system_log = {};
          http = {
            use_x_forwarded_for = true;
            trusted_proxies = [
              "127.0.0.1"
              "::1"
            ];
          };
          # Includes dependencies for a basic setup
          # https://www.home-assistant.io/integrations/default_config/
          script = import ./script.nix;
          "automation lights" = import ./automations/automation-lights.nix;
          "automation gate" = import ./automations/automation-gate.nix;
          "automation utils" = import ./automations/automation-utils.nix;
          "automation ui" = "!include automations.yaml";
        };
      };
    };
    networking.firewall.allowedTCPPorts = [8123 21064];
    networking.firewall.allowedUDPPorts = [21064];

    systemd.tmpfiles.rules = [
      "f ${config.services.home-assistant.configDir}/automations.yaml 0755 hass hass"
    ];

    environment.persistence = mkIf config.device.core.storage.enablePersistence {
      "/persist" = {
        directories = ["/var/lib/hass"];
      };
    };
  };
}
