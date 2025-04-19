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
    sops.secrets = {
      config_ssl_fullchain = {
        sopsFile = "${self}/secrets/services/config/secrets.yaml";
        owner = "nginx";
        group = "nginxs";
      };
      config_ssl_key = {
        sopsFile = "${self}/secrets/services/config/secrets.yaml";
        owner = "nginx";
        group = "nginx";
      };
    };

    device.server.nix-configurator.api.enable = lib.mkDefault true;
    services.nginx = {
      virtualHosts."config.internal.joka00.dev" = {
        forceSSL = true;
        sslCertificate = config.sops.secrets.config_ssl_fullchain.path;
        sslCertificateKey = config.sops.secrets.config_ssl_key.path;
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
