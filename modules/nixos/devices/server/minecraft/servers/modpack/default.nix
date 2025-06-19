inputs: {pkgs, ...}: let
  inherit (inputs.nix-minecraft.lib) collectFilesAt;
  modpack = pkgs.fetchzip {
    url = "https://curseforge.com/api/v1/mods/1178965/files/6658547/download";
    hash = "sha256-UmujOYvkUNaNVnlpcz+al8GGAi1XlPjkiPs9Lzty6L8=";
    extension = "zip";
    stripRoot = false;
  };
  forge = pkgs.callPackage ./forge.nix {inherit pkgs;};
  forgeServer = pkgs.callPackage ./forge-server.nix {inherit pkgs forge;};
in {
  networking.firewall = {
    allowedTCPPorts = [25572 24454];
    allowedUDPPorts = [25572 24454];
  };
  services.minecraft-servers.servers.modpack = {
    enable = true;
    enableReload = true;
    package = forgeServer;
    jvmOpts = (import ../../flags.nix) "8G";
    whitelist = import ../../whitelist.nix;
    serverProperties = {
      server-port = 25572;
      online-mode = true;
      enable-rcon = true;
      white-list = true;
      gamemode = 0;
      difficulty = 2;
      max-players = 5;
      view-distance = 16;
      simulation-distance = 16;
      force-gamemode = true;
      "rcon.password" = "@RCON_PASSWORD@";
      "rcon.port" = 24472;
    };

    files = {
      config = "${modpack}/config";
      defaultconfigs = "${modpack}/defaultconfigs";
      kubejs = "${modpack}/kubejs";
      modernfix = "${modpack}/modernfix";
      "world/datapacks/sleep.zip" = pkgs.fetchurl rec {
        name = "sleep";
        url = "https://cdn.modrinth.com/data/WTzuSu8P/versions/pw8ctTLy/Sleep-%5B1.20.1%5D-v.2.1.2.zip";
        hash = "sha256-x7W6lc6Z6WgROlI7Zuu6vyv8N0F+sjQaGFsMGfK0rjI=";
      };
    };
    symlinks =
      collectFilesAt modpack "mods"
      // {
        global_packs = "${modpack}/global_packs";
        "mods/BlueMap.jar" = pkgs.fetchurl rec {
          url = "https://cdn.modrinth.com/data/swbUV1cr/versions/aHbq9KFB/BlueMap-5.3-forge-1.20.jar";
          hash = "sha256-p4+Q4Auy8zMrwEXKJ3BTquay6mdtnTInE8u9wFjwBMU=";
        };
      };
  };
  services.nginx.virtualHosts."modpack.joka00.dev" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://localhost:8100";
    };
  };
}
