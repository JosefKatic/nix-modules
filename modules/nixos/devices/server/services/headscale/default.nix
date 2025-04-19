{
  self,
  config,
  lib,
  ...
}: let
  cfg = config.device.server.services.headscale;
in {
  options.services.headscale = {
    settings.oidc.allowed_groups = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = lib.mdDoc ''
        Groups allowed to authenticate even if not in allowedDomains.
      '';
      example = ["headscale"];
    };
  };
  options.device.server.services = {
    headscale = {
      enable = lib.mkEnableOption "Enable headscale server";
      domain = lib.mkOption {
        type = lib.types.str;
        default = "vpn.joka00.dev";
        description = "The domain name for the headscale server";
      };
      port = lib.mkOption {
        type = lib.types.int;
        default = 8080;
        description = "The port of the headsc ale server";
      };
    };
  };

  config = lib.mkIf (cfg.enable) {
    services = {
      headscale = {
        enable = true;
        address = "0.0.0.0";
        port = cfg.port;
        settings = {
          dns = {
            base_domain = "clients.joka00.dev";
            override_local_dns = true;
            nameservers.global = [
              "100.64.0.4"
              "169.254.169.254"
              "1.1.1.1"
            ];
            search_domains = [
              "clients.joka00.dev"
              "internal.joka00.dev"
              "oraclevcn.com"
            ];
          };
          server_url = "https://${cfg.domain}";
          logtail.enabled = false;
          ip_prefixes = [
            "100.64.0.0/10"
            "fd7a:115c:a1e0::/48"
          ];
          oidc = {
            only_start_if_oidc_is_available = true;
            client_id = "headscale-vpn";
            client_secret_path = config.sops.secrets.headscale_secret.path;
            issuer = "https://sso.joka00.dev/realms/21bb13ca-8130-423c-ac0f-85de48db99bb";
            scope = ["openid" "profile" "email"];
            # allowed_groups = ["headscale"];
          };
        };
      };

      nginx.virtualHosts.${cfg.domain} = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://localhost:${toString config.services.headscale.port}";
          proxyWebsockets = true;
        };
      };
    };

    sops.secrets.headscale_secret = {
      sopsFile = "${self}/secrets/services/headscale/secrets.yaml";
      owner = "headscale";
      group = "headscale";
    };
    environment.systemPackages = [config.services.headscale.package];
    environment.persistence = lib.mkIf config.device.core.storage.enablePersistence {
      "/persist" = {
        directories = [
          "/var/lib/headscale"
        ];
      };
    };
  };
}
