{
  self,
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [./devices.nix];

  options.device.server.hydra = {
    enable = lib.mkEnableOption "Hydra CI";
  };

  config = lib.mkIf config.device.server.hydra.enable {
    # https://github.com/NixOS/nix/issues/4178#issuecomment-738886808
    systemd.services.hydra-evaluator.environment.GC_DONT_GC = "true";

    services = {
      hydra = {
        enable = true;
        package = pkgs.hydra_unstable;
        hydraURL = "https://hydra.joka00.dev";
        notificationSender = "josef@joka00.dev";
        listenHost = "localhost";
        smtpHost = "localhost";
        useSubstitutes = true;
        extraConfig =
          /*
          xml
          */
          ''
            Include ${config.sops.secrets.hydra-gh-auth.path}
            max_unsupported_time = 30
            <githubstatus>
              jobs = .*
              useShortContext = true
            </githubstatus>
          '';
        extraEnv = {
          HYDRA_DISALLOW_UNFREE = "0";
        };
      };
      nginx.virtualHosts = {
        "hydra.joka00.dev" = {
          forceSSL = true;
          useACMEHost = "joka00.dev";
          locations = {
            "~* ^/shield/([^\\s]*)".return = "302 https://img.shields.io/endpoint?url=https://hydra.joka00.dev/$1/shield";
            "/".proxyPass = "http://localhost:${toString config.services.hydra.port}";
          };
        };
      };
    };
    users.users = let
      hydraGroup = config.users.users.hydra.group;
    in {
      hydra-queue-runner.extraGroups = [hydraGroup];
      hydra-www.extraGroups = [hydraGroup];
    };
    sops.secrets = let
      hydraUser = config.users.users.hydra.name;
      hydraGroup = config.users.users.hydra.group;
    in {
      hydra-gh-auth = {
        sopsFile = "${self}/secrets/services/hydra/secrets.yaml";
        owner = hydraUser;
        group = hydraGroup;
        mode = "0440";
      };
      nix-ssh-key = {
        sopsFile = "${self}/secrets/services/hydra/secrets.yaml";
        owner = hydraUser;
        group = hydraGroup;
        mode = "0440";
      };
    };

    environment.persistence = {
      "/persist".directories = ["/var/lib/hydra"];
    };
  };
}
