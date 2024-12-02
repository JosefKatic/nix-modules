{
  config,
  lib,
  self,
  pkgs,
  ...
}: let
  cfg = config.device.server.web-config.client;
in {
  options.device.server.web-config.client = {
    enable = lib.mkOption {
      default = false;
      description = ''
        Enable the web-config client.
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    services.nginx = {
      enable = true;
      virtualHosts."devices.joka00.dev" = {
        enableACME = true;
        forceSSL = true;
        root = ${pkgs.web-config-client}";
      };
    };
  };
}
