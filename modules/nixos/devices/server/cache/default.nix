{
  self,
  config,
  pkgs,
  lib,
  ...
}: {
  options.device.server.cache = {
    enable = lib.mkEnableOption "Enable cache service";
  };

  config = lib.mkIf config.device.server.cache.enable {
    sops.secrets.cache-sig-key = {
      sopsFile = "${self}/secrets/services/hydra/secrets.yaml";
    };

    services = {
      nix-serve = {
        enable = true;
        secretKeyFile = config.sops.secrets.cache-sig-key.path;
        package = pkgs.nix-serve;
      };
      nginx.virtualHosts."cache.joka00.dev" = {
        listenAddresses = ["193.41.237.192"];
        forceSSL = true;
        enableACME = true;
        locations."/".extraConfig = ''
          proxy_pass http://localhost:${toString config.services.nix-serve.port};
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        '';
      };
    };
  };
}
