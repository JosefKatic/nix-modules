{
  self,
  config,
  lib,
  pkgs,
  ...
}: {
  options.device.server.auth = {
    keycloak.enable = lib.mkEnableOption "Enable keycloak";
  };

  config = lib.mkIf config.device.server.auth.keycloak.enable {
    # Just the device running the keycloak server needs to be enrolled as the IPA device
    security.ipa = {
      enable = true;
      server = "ipa01.de.auth.joka00.dev";
      offlinePasswords = true;
      cacheCredentials = true;
      realm = "AUTH.JOKA00.DEV";
      domain = config.networking.domain;
      basedn = "dc=auth,dc=joka00,dc=dev";
      certificate = pkgs.fetchurl {
        url = http://ipa01.de.auth.joka00.dev/ipa/config/ca.crt;
        sha256 = "0ja5pb14cddh1cpzxz8z3yklhk1lp4r2byl3g4a7z0zmxr95xfhz";
      };
    };

    services.nginx = {
      virtualHosts = {
        "auth.joka00.dev" = {
          listenAddresses = ["193.41.237.192"];
          forceSSL = true;
          enableACME = true;
          locations = {
            "/" = {
              proxyPass = "http://localhost:${toString config.services.keycloak.settings.http-port}/";
            };
          };
        };
      };
    };

    sops.secrets.keycloak_db = {
      sopsFile = "${self}/secrets/services/auth/secrets.yaml";
    };

    sops.secrets.keycloak = {
      sopsFile = "${self}/secrets/services/auth/secrets.yaml";
    };

    services.keycloak = {
      enable = true;
      database = {
        type = "postgresql";
        createLocally = true;
        username = "admin";
        passwordFile = config.sops.secrets.keycloak_db.path;
      };
      settings = {
        hostname = "auth.joka00.dev";
        http-relative-path = "/";
        http-host = "127.0.0.1";
        http-port = 3880;
        https-port = 38443;
        proxy-headers = "xforwarded";
        http-enabled = true;
        sslCertificate = "/var/lib/acme/auth.joka00.dev/cert.pem";
        sslCertificateKey = "/var/lib/acme/auth.joka00.dev/key.pem";
      };
    };
  };
}
