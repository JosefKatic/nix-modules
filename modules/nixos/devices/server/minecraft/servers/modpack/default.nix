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
  services.minecraft-servers.servers.modpack = {
    enable = true;
    enableReload = true;
    package = forgeServer;
    jvmOpts = (import ../../flags.nix) "8G";
    whitelist = import ../../whitelist.nix;
    serverProperties = {
      server-port = 25572;
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
      "rcon.port" = 24472;
    };

    files = {
      config = "${modpack}/config";
      defaultconfigs = "${modpack}/defaultconfigs";
      kubejs = "${modpack}/kubejs";
      modernfix = "${modpack}/modernfix";
      "config/pcf-common.toml".value = {
        forwardingSecret = "@VELOCITY_FORWARDING_SECRET@";
      };
    };
    symlinks =
      collectFilesAt modpack "mods"
      // {
        global_packs = "${modpack}/global_packs";
        "mods/proxy-compatible-forge" = pkgs.fetchurl rec {
          pname = "proxy-compatible-forge";
          version = "1.1.6";
          url = "https://github.com/adde0109/Proxy-Compatible-Forge/releases/download/1.1.6/${pname}-${version}.jar";
          hash = "sha256-wimwdYrRTm9anbpu9IPkssQyuBvoTgaSiBY/IZlYNrk=";
        };
      };
  };
}
