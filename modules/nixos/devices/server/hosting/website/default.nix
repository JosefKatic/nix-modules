inputs: {
  config,
  pkgs,
  lib,
  self,
  ...
}: let
  website = inputs.web.packages.${pkgs.system}.default;
  # pgpKey = "${self}home/joka/pgp.asc";
  # sshKey = "${self}/home/joka/ssh.pub";
  days = n: toString (n * 60 * 60 * 24);
in {
  options.device.server.hosting.website = {
    enable = lib.mkEnableOption "Enable website hosting";
  };
  config = lib.mkIf config.device.server.hosting.website.enable {
    services.nginx.virtualHosts = {
      "joka00.dev" = {
        forceSSL = true;
        enableACME = true;
        locations = {
          "/" = {
            root = "${website}/public";
          };
          "/assets/" = {
            root = "${website}/public";
            extraConfig = ''
              add_header Cache-Control "max-age=${days 30}";
            '';
          };

          # "=/pgp.asc".alias = pgpKey;
          # "=/pgp".alias = pgpKey;
          # "=/ssh.pub".alias = sshKey;
          # "=/ssh".alias = sshKey;
        };
      };
    };
  };
}
