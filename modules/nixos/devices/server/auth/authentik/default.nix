{
  self,
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.devices.server.auth;
in {
  options.devices.server.auth.authentik = {
    enable = lib.mkEnableOption "Enable authentik";
  };
  config = lib.mkIf cfg.authentik.enable {
    sops.secrets.authentik-env = {
      owner = "authentik";
      group = "authentik";
      mode = "0440";
      sopsFile = "${self}/secrets/services/auth/secrets.yaml";
    };
    services = {
      authentik = {
        enable = true;
        # The environmentFile needs to be on the target host!
        # Best use something like sops-nix or agenix to manage it
        environmentFile = config.sops.secrets.authentik-env.path;
        settings = {
          email = {
            host = "smtp.protonmail.ch";
            port = 587;
            username = "auth@joka00.dev";
            use_tls = true;
            use_ssl = false;
            from = "auth@joka00.dev";
          };
          disable_startup_analytics = true;
          avatars = "initials";
        };

        #   traefik = {
        #     dynamicConfigOptions = {
        #       http = {
        #         middlewares = {
        #           authentik = {
        #             forwardAuth = {
        #               tls.insecureSkipVerify = true;
        #               address = "https://localhost:9443/outpost.goauthentik.io/auth/traefik";
        #               trustForwardHeader = true;
        #               authResponseHeaders = [
        #                 "X-authentik-username"
        #                 "X-authentik-groups"
        #                 "X-authentik-email"
        #                 "X-authentik-name"
        #                 "X-authentik-uid"
        #                 "X-authentik-jwt"
        #                 "X-authentik-meta-jwks"
        #                 "X-authentik-meta-outpost"
        #                 "X-authentik-meta-provider"
        #                 "X-authentik-meta-app"
        #                 "X-authentik-meta-version"
        #               ];
        #             };
        #           };
        #         };

        #         services = {
        #           auth.loadBalancer.servers = [
        #             {
        #               url = "http://localhost:9000";
        #             }
        #           ];
        #         };

        #         routers = {
        #           auth = {
        #             entryPoints = ["websecure"];
        #             rule = "Host(`auth.joka00.dev`) || HostRegexp(`{subdomain:[a-z0-9]+}.joka00.dev`) && PathPrefix(`/outpost.goauthentik.io/`)";
        #             service = "auth";
        #             tls.certResolver = "letsencrypt";
        #           };
        #         };
        #       };
        #     };
        #   };
      };
    };
  };
}
