{
  config,
  lib,
  pkgs,
  options,
  ...
}: let
  cfg = config.device.core;
  hasOptinPersistence = config.environment.persistence ? "/persist";
in {
  options.device.core = {
    network = {
      domain = lib.mkOption {
        type = lib.types.str;
        default = "clients.joka00.dev";
        description = "The domain name for the network";
      };
      services = {
        enableNetworkManager = lib.mkEnableOption "Enable NetworkManager, keep disabled on servers";
        enableAvahi = lib.mkEnableOption "Enable Avahi, keep disabled on servers";
        enableResolved = lib.mkEnableOption "Enable resolved, keep disabled on servers";
      };
      static = {
        enable = lib.mkEnableOption "Enable static network configuration";
        interfaces = lib.mkOption {
          type = lib.types.attrs;
          default = {};
        };
        defaultGateway = lib.mkOption {
          type = lib.types.attrs;
          default = {};
        };
        nameservers = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
        };
        search = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
        };
      };
    };
  };

  config = {
    networking =
      {
        domain = cfg.network.domain;
        extraHosts = lib.mkIf (config.device.server.auth.freeipa.enable == false) ''
          100.64.0.4 ipa.internal.joka00.dev
        '';
        # extraHosts = import ./blocker/etc-hosts.nix;
        firewall = {
          enable = true;
          trustedInterfaces = ["tailscale0"];
          checkReversePath = "loose";
          allowedUDPPorts = [
            config.services.tailscale.port
          ];
        };
        networkmanager = lib.mkIf cfg.network.services.enableNetworkManager {
          enable = cfg.network.services.enableNetworkManager;
          dns = "systemd-resolved";
        };
      }
      // lib.optionalAttrs (cfg.network.services.enableNetworkManager == false && cfg.network.static.enable) {
        dhcpcd.enable = false;
        interfaces = cfg.network.static.interfaces;
        defaultGateway = cfg.network.static.defaultGateway;
        nameservers = cfg.network.static.nameservers;
        search = cfg.network.static.search;
      };
    systemd.network.wait-online.enable = lib.mkIf cfg.network.services.enableNetworkManager false;
    services = {
      tailscale = {
        enable = true;
        extraUpFlags = ["--login-server https://vpn.joka00.dev"];
        useRoutingFeatures =
          if config.device.type == "server"
          then "server"
          else "client";
      };
      avahi = {
        enable = cfg.network.services.enableAvahi;
        nssmdns4 = true;
      };

      openssh = {
        enable = true;
        settings.UseDns = true;
      };

      # DNS resolver
      resolved.enable = cfg.network.services.enableResolved;
      # Just to be sure it won't fail
      resolved.fallbackDns = ["1.1.1.1"];
    };
    environment.persistence = lib.mkIf config.device.core.storage.enablePersistence {
      "/persist" = {
        directories = [
          "/var/lib/tailscale"
          "/var/lib/ipa-client"
          # Caching wouldn't work
          "/var/lib/sssd"
          "/var/lib/sss"
        ];
        files = ["/etc/krb5.keytab"];
      };
    };
  };
}
