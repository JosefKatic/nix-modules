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
    extraStartPre = ''
      rm mods/connectivity*.jar
    '';
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
        "mods/bungeeforge" = pkgs.fetchurl rec {
          pname = "bungeeforge";
          version = "1.0.6";
          url = "https://github.com/caunt/${pname}/releases/download/v${version}/${pname}-1.20.1.jar";
          hash = "sha256-lXZ9m+YgKt59bFzugpTzrbq7EDixDQDpMzxZIgiZ/Ck=";
        };
      };
  };
}
