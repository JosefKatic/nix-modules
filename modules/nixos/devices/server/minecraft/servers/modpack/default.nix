inputs: {pkgs, ...}: let
  inherit (inputs.nix-minecraft.lib) collectFilesAt;
  modpack = pkgs.fetchzip {
    url = "https://curseforge.com/api/v1/mods/1178965/files/6556641/download";
    hash = "sha256-c8EBKJJKGLgNqgdj39Roqdn3uzooAx81MUqMULawAIE=";
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
    };
    symlinks =
      collectFilesAt modpack "mods"
      // {
        global_packs = "${modpack}/global_packs";
        "mods/BlueMap.jar" = pkgs.fetchurl rec {
          url = "https://cdn.modrinth.com/data/swbUV1cr/versions/gPUpIIVC/bluemap-5.7-forge.jar";
          hash = "sha256-15aYx+N2a5eJtuc/CtUg8yFvpQRnWkNBxC+Rg3z1xD4=";
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
