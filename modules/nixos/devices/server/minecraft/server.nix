{
  self,
  config,
  lib,
  ...
}: {
  options.device.server.minecraft = {
    enable = lib.mkEnableOption "Enable Minecraft Server";
  };

  config = lib.mkIf config.device.server.minecraft.enable {
    sops.secrets.minecraft-secrets = {
      owner = "minecraft";
      group = "minecraft";
      mode = "0440";
      # VELOCITY_FORWARDING_SECRET, DATABASE_PASSWORD
      sopsFile = "${self}/secrets/services/minecraft/secrets.yaml";
    };
    services.minecraft-servers = {
      enable = true;
      eula = true;
      environmentFile = config.sops.secrets.minecraft-secrets.path;
      managementSystem = {
        tmux.enable = false;
        systemd-socket.enable = true;
      };
    };

    services.mysql = {
      ensureDatabases = ["minecraft"];
      ensureUsers = [
        {
          name = "minecraft";
          ensurePermissions = {
            "minecraft.*" = "ALL PRIVILEGES";
          };
        }
      ];
    };
    # Set minecrafts' password (the plugins don't play well with socket auth)
    users.users.mysql.extraGroups = ["minecraft"]; # Get access to the secret
    systemd.services.mysql.postStart = lib.mkAfter ''
      source ${config.sops.secrets.minecraft-secrets.path}
      ${config.services.mysql.package}/bin/mysql <<EOF
      ALTER USER 'minecraft'@'localhost'
      IDENTIFIED VIA unix_socket OR mysql_native_password
      USING PASSWORD('$DATABASE_PASSWORD');
      EOF
    '';
  };
}
