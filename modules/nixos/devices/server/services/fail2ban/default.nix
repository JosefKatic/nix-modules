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
      maxretry = 5;
      ignoreIP = [
        # Whitelist some subnets
        "10.0.0.0/8"
        "172.16.0.0/12"
        "100.64.0.0/10'"
        "192.168.0.0/16"
      ];
      bantime = "24h"; # Ban IPs for one day on the first ban
      bantime-increment = {
        enable = true; # Enable increment of bantime after each violation
        multipliers = "1 2 4 8 16 32 64";
        maxtime = "168h"; # Do not ban for more than 1 week
        overalljails = true; # Calculate the bantime based on all the violations
      };
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
