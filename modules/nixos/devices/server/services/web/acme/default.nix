{
  config,
  lib,
  ...
}: {
  options.device.server.services.web.acme.enable = lib.mkEnableOption "Enable ACME";

  config = lib.mkIf config.device.server.services.web.acme.enable {
    # Enable acme for usage with nginx vhosts
    security.acme = {
      defaults.email = "josef+acme@joka00.dev";
      acceptTerms = true;
      certs."joka00.dev" = {
        domain = "joka00.dev";
        extraDomainNames = ["*.joka00.dev"];
        dnsProvider = "godaddy";
        dnsPropagationCheck = true;
        credentialsFile = config.sops.secrets.acme-secrets.path;
      };
    };

    environment.persistence = lib.mkIf config.device.core.storage.enablePersistence {
      "/persist" = {
        directories = [
          "/var/lib/acme"
        ];
      };
    };
  };
}
