{
  config,
  lib,
  self,
  ...
}: let
  cfg = config.device.server.web-config.server;
in {
  options.device.server.web-config.server = {
    enable = lib.mkOption {
      default = false;
      description = ''
        Enable the web-config server.
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    environment.persistence = lib.mkIf (config.device.core.storage.enablePersistence) {
      "/persist" = {
        directories = ["/var/lib/web-config-api"];
      };
    };
    sops.secrets.github_token = {
      sopsFile = "${self}/secrets/services/web-config/secrets.yaml";
    };
    sops.secrets.headscale_token = {
      sopsFile = "${self}/secrets/services/web-config/secrets.yaml";
    };

    services.nginx = {
      virtualHosts."api.devices.joka00.dev" = {
        listenAddresses = ["100.0."];
        forceSSL = true;
        enableACME = true;
        locations = {
          "/" = {
            proxyPass = "http://localhost:${toString config.device.server.web-config.server.settings.port}";
          };
        };
      };
    };
    services.web-config.server = {
      enable = cfg.enable;
      settings = {
        github = {
          tokenFile = config.sops.secrets.github_token.path;
        };
        redis = {
          host = "localhost";
          port = 6379;
        };
        headscale = {
          host = "https://vpn.joka00.dev";
          tokenFile = config.sops.secrets.headscale_token.path;
        };
      };
    };
    services.redis.servers."git-queue" = {
      enable = true;
      port = 6379;
    };
  };
}
