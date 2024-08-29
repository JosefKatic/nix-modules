inputs: {
  pkgs,
  config,
  lib,
  ...
}: let
  servers = config.services.minecraft-servers.servers;
  proxyFlags = memory: "-Xms${memory} -Xmx${memory} -XX:+UseG1GC -XX:G1HeapRegionSize=4M -XX:+UnlockExperimentalVMOptions -XX:+ParallelRefProcEnabled -XX:+AlwaysPreTouch -XX:MaxInlineLevel=15";
in {
  imports = [
    ./huskchat.nix
  ];

  config = lib.mkIf config.device.server.minecraft.enable {
    networking.firewall = {
      allowedTCPPorts = [25565];
      allowedUDPPorts = [25565 24454];
    };

    services.minecraft-servers.servers.proxy = {
      enable = true;

      enableReload = true;
      extraReload = ''
        echo 'velocity reload' > /run/minecraft-server/proxy.stdin
      '';

      package = inputs.nix-minecraft.velocity-server; # Latest build
      jvmOpts = proxyFlags "1G";

      files = {
        "velocity.toml".value = {
          config-version = "2.5";
          bind = "0.0.0.0:25565";
          motd = "JZSM";
          player-info-forwarding-mode = "modern";
          forwarding-secret-file = "";
          forwarding-secret = "@VELOCITY_FORWARDING_SECRET@";
          online-mode = true;
          show-max-players = 5;
          servers = {
            # lobby = "localhost:${toString servers.lobby.serverProperties.server-port}";
            survival = "localhost:${toString servers.survival.serverProperties.server-port}";
            try = ["survival"];
          };
          forced-hosts = {
            "survival.joka00.dev" = [
              "survival"
            ];
          };
          query = {
            enabled = true;
            port = 25565;
          };
          advanced = {
            login-ratelimite = 500;
          };
        };
      };
    };
  };
}
