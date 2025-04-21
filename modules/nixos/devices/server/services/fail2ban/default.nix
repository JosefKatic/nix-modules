{
  config,
  lib,
  ...
}: {
  options.device.server.services.fail2ban = {
    enable = lib.mkEnableOption "Enable fail2ban";
  };
  config = lib.mkIf config.device.server.services.fail2ban.enable {
    services.fail2ban = {
      enable = true;
      # Ban IP after 5 failures
      maxretry = 10;
      ignoreIP = [
        # Whitelist some subnets
        "10.0.0.0/8"
        "100.64.0.0/10"
        "172.16.0.0/12"
        "192.168.0.0/16"
      ];
      bantime = "24h"; # Ban IPs for one day on the first ban
      bantime-increment = {
        enable = true; # Enable increment of bantime after each violation
        multipliers = "1 2 4 8 16 32 64";
        maxtime = "168h"; # Do not ban for more than 1 week
        overalljails = true; # Calculate the bantime based on all the violations
      };
      jails.nginx-bad-requests = {
        enabled = true;
        filter = "nginx-bad-requests";
        action = "iptables[name=nginx-bad-requests, port=http, protocol=tcp]";
        logpath = "/var/log/nginx/access.log";
        maxretry = 15;
        bantime = "1h";
        findtime = "10m";
      };

      filters.nginx-bad-requests = ''
        [Definition]
        # Matches common 4xx codes from bots, scrapers, brute force attempts, etc.
        failregex = ^<HOST> -.*"(GET|POST|HEAD|PUT|DELETE).*HTTP.*" (403|404|429|400|401)
        ignoreregex =
      '';
    };
    environment.persistence = lib.mkIf config.device.core.storage.enablePersistence {
      "/persist" = {
        directories = [
          "/etc/fail2ban"
          "/var/lib/fail2ban"
        ];
      };
    };
  };
}
