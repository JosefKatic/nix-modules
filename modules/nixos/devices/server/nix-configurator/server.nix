{
  config,
  lib,
  self,
  ...
}: let
  cfg = config.device.server.nix-configurator.api;
in {
  options.device.server.nix-configurator.api = {
    enable = lib.mkOption {
      default = false;
      description = ''
        Enable the nix-configurator api.
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    environment.persistence = lib.mkIf (config.device.core.storage.enablePersistence) {
      "/persist" = {
        directories = ["/var/lib/nix-configurator-api"];
      };
    };
    sops.secrets.github_token = {
      sopsFile = "${self}/secrets/services/nix-configurator/secrets.yaml";
    };
    sops.secrets.headscale_token = {
      sopsFile = "${self}/secrets/services/nix-configurator/secrets.yaml";
    };

    services.nginx = {
      virtualHosts."api.devices.joka00.dev" = {
        listenAddresses = ["100.64.0.7"];
        forceSSL = true;
        enableACME = true;
        locations = {
          "/" = {
            proxyPass = "http://localhost:${toString config.device.server.nix-configurator.api.settings.port}";
          };
        };
      };
    };
    services.nix-configurator.api = {
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
