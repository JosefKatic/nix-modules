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
    device.server.nix-configurator.api.enable = lib.mkDefault true;
    services.nginx = {
      virtualHosts."config.joka00.dev" = {
        locations."/" = {
          root = "${inputs.nix-configurator-web.packages.${pkgs.system}.default}";
          index = "index.html";
          extraConfig = ''
            try_files $uri $uri/ /index.html =404;
          '';
        };
      };
    };
  };
}
