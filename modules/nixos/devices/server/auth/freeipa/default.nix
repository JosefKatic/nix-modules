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
      freeipa_cert = {
        sopsFile = "${self}/secrets/services/auth/secrets.yaml";
      };
      freeipa_cert_key = {
        sopsFile = "${self}/secrets/services/auth/secrets.yaml";
      };
    };
    networking.extraHosts = ''
      10.24.0.8 ipa01.de.auth.joka00.dev
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
        "100.64.0.1:53:53"
        "127.0.0.1:8000:80"
        "127.0.0.1:8443:443"
        "100.64.0.1:389:389"
        "100.64.0.1:636:636"
        "100.64.0.1:88:88"
        "100.64.0.1:464:464"
        "100.64.0.1:88:88/udp"
        "100.64.0.1:53:53/udp"
        "100.64.0.1:464:464/udp"
      ];
      extraOptions = [
        "--read-only"
        "-h=ipa01.de.auth.joka00.dev"
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
          ${pkgs.podman}/bin/podman network create --disable-dns --gateway=10.24.0.1 --subnet=10.24.0.0/28 br-services
      '';
    };
    networking.firewall.interfaces."tailscale0".allowedTCPPorts = [53 80 3480 88 389 443 34443 464 636];
    networking.firewall.interfaces."tailscale0".allowedUDPPorts = [53 88 123 464];

    services = {
      nginx.virtualHosts."ipa01.de.auth.joka00.dev" = {
        locations."/" = {
          proxyPass = "http://localhost:8000";
        };
      };
    };
  };
}
