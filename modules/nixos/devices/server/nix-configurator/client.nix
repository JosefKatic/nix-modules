{
  config,
  lib,
  self,
  pkgs,
  ...
}: let
  cfg = config.device.server.nix-configurator.client;
in {
  options.device.server.nix-configurator.client = {
    enable = lib.mkOption {
      default = false;
      description = ''
        Enable the nix-configurator client.
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    services.nginx = {
      enable = true;
      virtualHosts."devices.joka00.dev" = {
        listenAddresses = ["100.64.0.7"];
        enableACME = true;
        forceSSL = true;
        root = "${pkgs.nix-configurator-web}";
      };
    };
  };
}
