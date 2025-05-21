inputs: {
  pkgs,
  config,
  lib,
  ...
}: let
  servers = config.services.minecraft-servers.servers;
  proxyFlags = memory: "-Xms${memory} -Xmx${memory} -XX:+UseG1GC -XX:G1HeapRegionSize=4M -XX:+UnlockExperimentalVMOptions -XX:+ParallelRefProcEnabled -XX:+AlwaysPreTouch -XX:MaxInlineLevel=15";
in {
  config = lib.mkIf config.device.server.minecraft.enable {
    imports = [
      ./huskchat.nix
      ./fallbackserver.nix
      ./librelogin.nix
      ./luckperms.nix
      ./velocitab.nix
    ];
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

      package = inputs.nix-minecraft.packages.${pkgs.system}.velocity-server; # Latest build
      jvmOpts = proxyFlags "1G";

      files = {
        "velocity.toml".value = {
          config-version = "2.5";
          bind = "0.0.0.0:25565";
          motd = "JZSM";
          player-info-forwarding-mode = "modern";
          forwarding-secret-file = "";
          forwarding-secret = "@VELOCITY_FORWARDING_SECRET@";
          online-mode = false;
          show-max-players = 5;
          servers = {
            limbo = "localhost:${toString servers.limbo.files."settings.yml".value.bind.port}";
            auth = "localhost:${toString servers.limbo.files."settings.yml".value.bind.port}";
            modpack = "localhost:${toString servers.modpack.serverProperties.server-port}";
            try = ["limbo"];
          };
          forced-hosts = {
            "modpack.joka00.dev" = [
              "modpack"
              "limbo"
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
        "plugins/ambassador/Ambassador.toml".value = {
          config-version = "1.1";
          disconnect-reset-message = "&eProsím připojte se znovu.";
          silence-warnings = true;
          server-switch-cancellation-time = 1200;
        };
      };
      symlinks = {
        "plugins/OwoVelocityPlugin.jar" = pkgs.fetchurl rec {
          pname = "OwoVelocityPlugin";
          version = "0.1.2";
          url = "https://github.com/wisp-forest/owo-velocity-plugin/releases/download/${version}/${pname}.jar";
          hash = "sha256-aiAlYdJV2tCxaCMWv9S0Opn29aMGHVyPiJ00ePe1CDw=";
        };
        "plugins/Ambassador-Velocity.jar" = pkgs.fetchurl rec {
          pname = "Ambassador";
          version = "1.4.5";
          url = "https://github.com/adde0109/Ambassador/releases/download/v${version}/Ambassador-Velocity-${version}-all.jar";
          hash = "sha256-fFemScOUhnLL7zWjuqj3OwRqxQnqj/pu4wCIkNNvLBc=";
        };
      };
    };
  };
}
