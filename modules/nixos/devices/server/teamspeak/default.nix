{
  config,
  lib,
  ...
}: let
  cfg = config.device.server;
in {
  options.device.server.teamspeak.enable = lib.mkEnableOption "Enable teamspeak server";

  config = lib.mkIf cfg.teamspeak.enable {
    services = {
      teamspeak3 = {
        enable = true;
        openFirewall = true;
        queryPort = 19102;
        defaultVoicePort = 29102;
        fileTransferPort = 39102;
      };
    };

    environment.persistence = lib.mkIf config.device.core.storage.enablePersistence {
      "/persist".directories = [
        "/var/lib/teamspeak3-server"
        "/var/log/teamspeak3-server"
      ];
    };
  };
}
