inputs: {
  config,
  lib,
  self,
  pkgs,
  ...
}: let
  cfg = config.device.server.nixConfigurator;
in {
  options.device.server.nixConfigurator = {
    enable = lib.mkOption {
      default = false;
      description = ''
        Enable the nix-configurator.
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    environment.persistence = lib.mkIf (config.device.core.storage.enablePersistence) {
      "/persist" = {
        directories = ["/var/lib/nix-configurator-api"];
      };
    };
    sops.secrets = {
      config_ssl_fullchain = {
        sopsFile = "${self}/secrets/services/nix-configurator/secrets.yaml";
        owner = "nginx";
        group = "nginx";
      };
      config_ssl_key = {
        sopsFile = "${self}/secrets/services/nix-configurator/secrets.yaml";
        owner = "nginx";
        group = "nginx";
      };
      github_token = {
        sopsFile = "${self}/secrets/services/nix-configurator/secrets.yaml";
        owner = "nix-configurator-api";
        group = "nix-configurator-api";
      };
      headscale_token = {
        sopsFile = "${self}/secrets/services/nix-configurator/secrets.yaml";
        owner = "nix-configurator-api";
        group = "nix-configurator-api";
      };
    };

    services.nginx = {
      virtualHosts."config.internal.joka00.dev" = {
        forceSSL = true;
        sslCertificate = config.sops.secrets.config_ssl_fullchain.path;
        sslCertificateKey = config.sops.secrets.config_ssl_key.path;
        extraConfig = ''
          allow 100.64.0.0/10;
          deny all;
        '';
        locations = {
          "/" = {
            root = "${inputs.nix-configurator-web.packages.${pkgs.system}.default}";
            index = "index.html";
            extraConfig = ''
              try_files $uri $uri/ /index.html =404;
            '';
          };
          "/api" = {
            proxyPass = "http://localhost:${toString config.services.nix-configurator.api.settings.port}/graphql";
            extraConfig = ''
              proxy_read_timeout 60s;
              proxy_set_header          Host            $host;
              proxy_set_header          X-Real-IP       $remote_addr;
              proxy_set_header          X-Forwarded-For $proxy_add_x_forwarded_for;
            '';
          };
          "/queues" = {
            proxyPass = "http://localhost:${toString config.services.nix-configurator.api.settings.port}/queues";
            extraConfig = ''
              proxy_read_timeout 60s;
              proxy_set_header          Host            $host;
              proxy_set_header          X-Real-IP       $remote_addr;
              proxy_set_header          X-Forwarded-For $proxy_add_x_forwarded_for;
            '';
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
