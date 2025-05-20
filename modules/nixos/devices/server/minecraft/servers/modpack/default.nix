inputs: {pkgs, ...}: let
  inherit (inputs.nix-minecraft.lib) collectFilesAt;
  modpack = pkgs.fetchzip {
    url = "https://www.dropbox.com/scl/fi/gl27yxvdh7n18x4x72isd/majnr.zip?dl=1";
    hash = "sha256-JYoEZS7hknMZgt76qxB2UcVnahnxhd6IEFxRpnYlyGs=";
    stripRoot = false;
  };
in {
  services.minecraft-servers.servers.modpack = {
    enable = true;
    enableReload = true;
    package = pkgs.callPackage ./forge-server.nix {};
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

    # Conflicts with bungeeforge
    extraStartPre = ''
      rm mods/connectivity*.jar
    '';
    files = {
      config = "${modpack}/config";
      resourcepacks = "${modpack}/resourcepacks";
      shaderpacks = "${modpack}/shaderpacks";
    };
    symlinks =
      collectFilesAt modpack "mods"
      // {
        "mods/bungeeforge-1.20.1.jar" = pkgs.fetchurl rec {
          pname = "bungeeforge";
          version = "1.0.6";
          url = "https://github.com/caunt/BungeeForge/releases/download/v${version}/bungeeforge-1.20.1.jar";
          hash = "sha256-lXZ9m+YgKt59bFzugpTzrbq7EDixDQDpMzxZIgiZ/Ck=";
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
