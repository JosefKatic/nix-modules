{
  self,
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.device.server.auth.freeipa;
  serviceName = "freeipa-server";
  service = "${config.virtualisation.oci-containers.backend}-${serviceName}";
in {
  options.device.server.auth.freeipa = {
    enable = lib.mkEnableOption "FreeIpa service";
    router = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "10.24.0.1";
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets = {
      freeipa = {
        sopsFile = "${self}/secrets/services/auth/secrets.yaml";
      };
    };
    networking.extraHosts = ''
      10.24.0.8 ipa.auth.joka00.dev
    '';
    environment.etc."resolv.conf".text = ''
      nameserver 10.24.0.8
      nameserver 1.1.1.1
      search tailff755.ts.net
      search joka00.dev
    '';
    environment.persistence = lib.mkIf config.device.core.storage.enablePersistence {
      "/persist" = {
        directories = [
          "/var/lib/containers"
          "/var/data/freeipa"
        ];
      };
    };
    systemd.services."podman-freeipa-server".after = ["tailscaled.service"];
    virtualisation.oci-containers.containers."${serviceName}" = {
      autoStart = true;
      image = "freeipa/freeipa-server:rocky-9";
      volumes = [
        "/var/data/freeipa:/data:Z"
        "${config.sops.secrets.freeipa.path}:/data/ipa-server-install-options:Z"
        "/run/secrets:/run/secrets"
      ];
      ports = [
        "0.0.0.0:636:636"
        "0.0.0.0:88:88"
        "0.0.0.0:464:464"
        "0.0.0.0:88:88/udp"
        "0.0.0.0:464:464/udp"
      ];
      extraOptions = [
        "--read-only"
        "-h=ipa.auth.joka00.dev"
        "--ip=10.24.0.8"
        "--network=br-services"
        "--sysctl=net.ipv6.conf.all.disable_ipv6=0"
      ];
      cmd = [
        "--unattended"
        "--realm=AUTH.JOKA00.DEV"
        "--domain=auth.joka00.dev"
        "--ntp-server=${cfg.router}"
        "--setup-dns"
        "--forwarder=1.1.1.1"
        # "--no-host-dns"
        "--no-reverse"
      ];
    };
    virtualisation.podman = {
      enable = true;
    };
    systemd.services.create-podman-network = with config.virtualisation.oci-containers; {
      serviceConfig.Type = "oneshot";
      wantedBy = ["podman-freeipa-server.service"];
      script = ''
        ${pkgs.podman}/bin/podman network exists br-services || \
          ${pkgs.podman}/bin/podman network create --gateway=10.24.0.1 --subnet=10.24.0.0/28 --parent=ens3 br-services
      '';
    };
    networking.firewall.interfaces."tailscale0".allowedTCPPorts = [80 3480 88 443 34443 464 636];
    networking.firewall.interfaces."tailscale0".allowedUDPPorts = [88 123 464];
    security.acme = {
      certs."auth.joka00.dev" = {
        domain = "auth.joka00.dev";
        extraDomainNames = ["auth.joka00.dev" "ipa.auth.joka00.dev"];
        webroot = "/var/lib/acme/acme-challenge";
      };
    };
    services = {
      nginx.virtualHosts."ipa.auth.joka00.dev" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = http://10.24.0.8:8000;
          extraConfig = ''
            proxy_set_header        Host $host;
            proxy_http_version      1.1;
            proxy_set_header        Upgrade $http_upgrade;
            proxy_set_header        Connection $connection_upgrade;
            proxy_set_header        X-Real-IP $remote_addr;
            proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header        X-Forwarded-Proto $scheme;
          '';
        };
      };
    };
  };
}
