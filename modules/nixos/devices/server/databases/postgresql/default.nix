{
  config,
  lib,
  ...
}: {
  options.device.server.databases.postgresql.enable = lib.mkEnableOption "Enable postgresql";
  config = lib.mkIf config.device.server.databases.postgresql.enable {
    services.postgresql.enable = true;

    environment.persistence = lib.mkIf config.device.core.storage.enablePersistence {
      "/persist".directories = [
        "/var/lib/postgresql"
      ];
    };
  };
}
