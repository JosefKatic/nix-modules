{
  self,
  lib,
  config,
  pkgs,
  device,
  ...
}: let
  inherit (config.networking) hostName;
  hosts = self.nixosConfigurations;
  pubKey = host: "${self}/config/nixos/${host}/ssh_host_ed25519_key.pub";
  # gitHost = hosts."strix".config.networking.hostName;

  # Sops needs acess to the keys before the persist dirs are even mounted; so
  # just persisting the keys won't work, we must point at /persist
  hasOptinPersistence = config.environment.persistence ? "/persist";
in {
  environment.etc."ssh/authorized_keys_command" = {
    mode = "0755";
    text = ''
      #!/bin/sh
      exec ${pkgs.sssd}/bin/sss_ssh_authorizedkeys "$@"
    '';
  };

  services.openssh = {
    enable = true;
    authorizedKeysCommand = "/etc/ssh/authorized_keys_command";
    authorizedKeysCommandUser = "nobody";
    settings = {
      # Harden
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      # Automatically remove stale sockets
      StreamLocalBindUnlink = "yes";
      # Allow forwarding ports to everywhere
      GatewayPorts = "clientspecified";
    };

    hostKeys = [
      {
        path = "${lib.optionalString hasOptinPersistence "/persist"}/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };

  programs.ssh = {
    # Each hosts public keyss
    knownHosts =
      builtins.mapAttrs (name: _: {
        publicKeyFile = pubKey name;
        extraHostNames =
          # Alias for localhost if it's the same host
          ["${name}.clients.joka00.dev"]
          ++ lib.optional (name == hostName) "localhost";
        # ++ (lib.optionals (name == gitHost) ["joka00.dev" "git.joka00.dev"]);
      })
      hosts;
  };

  # Passwordless sudo when SSH'ing with keys
  security.pam.sshAgentAuth = {
    enable = true;
    authorizedKeysFiles = ["/etc/ssh/authorized_keys.d/%u"];
  };
}
