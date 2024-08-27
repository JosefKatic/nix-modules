{
  self,
  config,
  lib,
  ...
}: {
  imports = [
    ./blocky
    ./homeassistant
    ./mosquitto
    ./zigbee2mqtt
  ];

  options.device.server.homelab = {
    enable = lib.mkEnableOption "Enable homelab services";
  };

  config = lib.mkIf config.device.server.homelab.enable {
    sops.secrets.acme-secrets = {
      sopsFile = "${self}/secrets/services/homelab/secrets.yaml";
    };

    device.server.services.web.acme.enable = true;
    security.acme.certs."joka00.dev" = {
      domain = "joka00.dev";
      extraDomainNames = ["*.joka00.dev" "*.remote.joka00.dev"];
      dnsProvider = "godaddy";
      dnsPropagationCheck = true;
      credentialsFile = config.sops.secrets.acme-secrets.path;
    };
  };
}
