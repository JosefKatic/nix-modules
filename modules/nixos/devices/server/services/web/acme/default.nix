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
