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
      10.24.0.8 ipa.internal.joka00.dev
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
        "80:80"
        "443:443"
        "53:53"
        "389:389"
        "636:636"
        "88:88"
        "464:464"
        "88:88/udp"
        "53:53/udp"
        "464:464/udp"
      ];
      extraOptions = [
        "--read-only"
        "-h=ipa.internal.joka00.dev"
        "--ip=10.24.0.8"
        "--network=br-services"
      ];
      cmd = [
        "--unattended"
        "--realm=INTERNAL.JOKA00.DEV"
        "--domain=INTERNAL.joka00.dev"
        "--setup-dns"
        "--forwarder=1.1.1.1"
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
          ${pkgs.podman}/bin/podman network create --disable-dns --gateway=10.24.0.1 --subnet=10.24.0.0/28 br-services
      '';
    };
    networking.firewall.interfaces."eno2".allowedTCPPorts = [53 80 3480 88 389 443 34443 464 636];
    networking.firewall.interfaces."eno2".allowedUDPPorts = [53 88 123 464];
    networking.firewall.interfaces."tailscale0".allowedTCPPorts = [53 80 3480 88 389 443 34443 464 636];
    networking.firewall.interfaces."tailscale0".allowedUDPPorts = [53 88 123 464];
    /*
       security.acme = {
      certs."auth.joka00.dev" = {
        domain = "auth.joka00.dev";
        extraDomainNames = ["auth.joka00.dev" "ipa.joka00.dev"];
        webroot = "/var/lib/acme/acme-challenge";
      };
    };
    services = {
      nginx.virtualHosts."ipa.joka00.dev" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          extraConfig = ''
            proxy_pass              https://ipa.joka00.dev;
            proxy_set_header        Host $host;
            proxy_set_header        Referer https://ipa.joka00.dev/ipa/ui;
            proxy_set_header        X-Real-IP $remote_addr;
            proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header        X-Forwarded-Proto https;
            proxy_connect_timeout   150;
            proxy_send_timeout      100;
            proxy_read_timeout      100;
            proxy_buffers           4 32k;
            client_max_body_size    200M;
            client_body_buffer_size 512k;
            keepalive_timeout       5;
            add_header              Strict-Transport-Security max-age=63072000;
            add_header              X-Frame-Options DENY;
            add_header              X-Content-Type-Options nosniff;
          '';
        };
      };
     };
    */
  };
}
