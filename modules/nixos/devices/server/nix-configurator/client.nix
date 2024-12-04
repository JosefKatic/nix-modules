inputs: {
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
        forceSSL = true;
        useACMEHost = "joka00.dev";
        root = "${inputs.nix-configurator-web.packages.${pkgs.system}.default}";
      };
    };
  };
}
