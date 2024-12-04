inputs: {
  self,
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.device.server.minecraft.enable {
    services.minecraft-servers.servers.survival = {
      enable = true;
      enableReload = true;
      package = inputs.nix-minecraft.legacyPackages.${pkgs.system}.paperServers.paper-1_21;
      jvmOpts = ((import ../../flags.nix) "6G") + "-Dpaper.disableChannelLimit=true";
      whitelist = import ../../whitelist.nix;
      serverProperties = {
        server-port = 25571;
        online-mode = false;
        enable-rcon = true;
        white-list = true;
        gamemode = 0;
        difficulty = 2;
        max-players = 5;
        view-distance = 16;
        simulation-distance = 16;
        force-gamemode = true;
        "rcon.password" = "@RCON_PASSWORD@";
        "rcon.port" = 24471;
      };
      files = {
        "config/paper-global.yml".value = {
          proxies.velocity = {
            enabled = true;
            online-mode = false;
            secret = "@VELOCITY_FORWARDING_SECRET@";
          };
          unsupported-settings = {
            allow-piston-duplication = true;
          };
        };
        "bukkit.yml".value = {
          settings.shutdown-message = "Servidor fechado (provavelmente reiniciando).";
        };
        "spigot.yml".value = {
          messages = {
            whitelist = "You have to be on whitelist!";
            unknown-command = "Unknown command.";
            restart = "Server is restarting!";
          };
        };
      };
      symlinks = {
        "datapacks/ServerSleep.zip" = pkgs.fetchurl rec {
          pname = "ServerSleep";
          url = "https://cdn.modrinth.com/data/Cw8IlnGM/versions/smQOT3XO/${pname}.zip";
          hash = "sha256-h2s7ODR+unGVp6LOZ60ga5OPo/t3SUKTlq/NmmXdq9E=";
        };
        "plugins/HidePLayerJoinQuit.jar" = pkgs.fetchurl rec {
          pname = "HidePLayerJoinQuit";
          version = "1.0";
          url = "https://github.com/OskarZyg/${pname}/releases/download/v${version}-full-version/${pname}-${version}-Final.jar";
          hash = "sha256-UjLlZb+lF0Mh3SaijNdwPM7ZdU37CHPBlERLR3LoxSU=";
        };
        "plugins/BlueMap.jar" = pkgs.fetchurl rec {
          pname = "BlueMap";
          version = "5.2";
          url = "https://github.com/BlueMap-Minecraft/${pname}/releases/download/v${version}/${pname}-${version}-paper.jar";
          hash = "sha256-5aKxbFgCxYdNVLisw8syOsAZaFhJ3h2JbFkumCqnOQo=";
        };
        "plugins/voicechat.jar" = pkgs.fetchurl rec {
          pname = "voicechat";
          version = "2.5.16";
          url = "https://cdn.modrinth.com/data/9eGKb6K1/versions/9yRemfrE/${pname}-bukkit-${version}.jar";
          hash = "sha256-axU4uyLByVof1SDqVyDhYxDeaxkDHXCFQBgPVxR1xnM=";
        };
        # "plugins/worldedit.jar" = pkgs.fetchurl rec {
        #   pname = "worldedit";
        #   version = "7.3.6";
        #   url = "https://cdn.modrinth.com/data/1u6JkXh5/versions/yAujLUIK/${pname}-bukkit-${version}.jar";
        #   hash = "sha256-85MQWheIaM/9mdvjnykGHESwx1vqy11apZwIDNQjyXk=";
        # };
      };
    };

    services.nginx.virtualHosts."survival.joka00.dev" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://localhost:8100";
      };
    };
  };
}
