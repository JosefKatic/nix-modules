{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) types mkIf mkEnableOption;
  cfg = config.device.server.homelab;
in {
  options.device.server.homelab = {
    blocky = {
      enable = mkEnableOption "Blocky DNS";
    };
  };

  config = mkIf cfg.blocky.enable {
    services.blocky = {
      enable = true;
      settings = {
        ports = {
          dns = "10.34.70.20:53,100.64.0.4:53";
          tls = "10.34.70.20:853,100.64.0.4:853";
          http = "10.34.70.20:4000";
          https = "10.34.70.20:4443";
        }; # Port for incoming DNS Queries.
        upstreams = {
          groups = {
            "default" = [
              # Using Cloudflare's DNS over HTTPS server for resolving queries.
              "https://one.one.one.one/dns-query"
            ];
          };
        };
        blocking = {
          blockType = "zeroIP";
          loading = {
            refreshPeriod = "4h";
            downloads = {
              timeout = "4m";
              cooldown = "10s";
            };
          };
          denylists = {
            malware = [
              "https://urlhaus.abuse.ch/downloads/hostfile/"
            ];
            ads = [
              "https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt"
              "https://someonewhocares.org/hosts/zero/hosts"
              # "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
              "https://raw.githubusercontent.com/notracking/hosts-blocklists/master/hostnames.txt"
              # "https://adaway.org/hosts.txt"
              "https://raw.githubusercontent.com/mitchellkrogza/Badd-Boyz-Hosts/master/hosts"
            ];
          };
          allowlists = {
            ads = let
              whitelist =
                pkgs.writeText
                "whitelist.txt"
                ''
                  s.youtube.com
                  googleadservices.com
                  www.googleadservices.com
                '';
            in [
              whitelist
            ];
          };
          clientGroupsBlock = {
            default = [
              "ads"
              "malware"
            ];
          };
        };
        customDNS = {
          customTTL = "1h";
          filterUnmappedTypes = true;
          mapping = {
            "hass.joka00.dev" = "10.34.70.20";
            "hass.remote.joka00.dev" = "100.64.0.4";
            "config.joka00.dev" = "100.64.0.7";
          };
        };
        bootstrapDns = [
          {
            upstream = "https://one.one.one.one/dns-query";
            ips = ["1.1.1.1" "1.0.0.1"];
          }
        ];
      };
    };

    networking.firewall.allowedTCPPorts = [53 4000 443];
    networking.firewall.allowedUDPPorts = [53];

    environment.persistence = mkIf config.device.core.storage.enablePersistence {
      "/persist" = {
        directories = ["/var/lib/private/blocky"];
      };
    };
  };
}
