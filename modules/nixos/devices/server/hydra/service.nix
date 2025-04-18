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
        hydraURL = "https://hydra.joka00.dev";
        notificationSender = "hydra@joka00.dev";
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
            <ldap>
              <config>
                <credential>
                  class = Password
                  password_field = password
                  password_type = self_check
                </credential>
                <store>
                  class = LDAP
                  ldap_server = ipa.internal.joka00.dev
                  <ldap_server_options>
                    timeout = 30
                  </ldap_server_options>
                  binddn = "uid=admin,cn=users,cn=accounts,dc=internal,dc=joka00,dc=dev"
                  Include ${config.sops.secrets.hydra-ldap-pass.path}
                  start_tls = 0
                  <start_tls_options>
                    verify = none
                  </start_tls_options>
                  user_basedn = "cn=users,cn=accounts,dc=internal,dc=joka00,dc=dev"
                  user_filter = "(&(objectClass=inetOrgPerson)(uid=%s))"
                  user_scope = one
                  user_field = uid
                  <user_search_options>
                    deref = always
                  </user_search_options>
                  # Important for role mappings to work:
                  use_roles = 1
                  role_basedn = "cn=groups,cn=accounts,dc=internal,dc=joka00,dc=dev"
                  role_filter = "(&(objectClass=groupOfNames)(member=%s))"
                  role_scope = one
                  role_field = cn
                  role_value = dn
                  <role_search_options>
                    deref = always
                  </role_search_options>
                </store>
              </config>
              <role_mapping>
                # Make all users in the hydra_admin group Hydra admins
                hydra_admin = admin
                # Allow all users in the dev group to eval jobsets, restart jobs and cancel builds
                dev = eval-jobset
                dev = restart-jobs
                dev = cancel-build
              </role_mapping>
            </ldap>

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
      hydra-ldap-pass = {
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
