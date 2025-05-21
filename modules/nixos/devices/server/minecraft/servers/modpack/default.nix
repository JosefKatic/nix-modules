inputs: {pkgs, ...}: let
  inherit (inputs.nix-minecraft.lib) collectFilesAt;
  modpack = pkgs.fetchzip {
    url = "https://www.dropbox.com/scl/fi/lj7j77yt851h5vkq9ezln/modpack.zip?rlkey=xxoqjorlxuv04an7mznqavv8i&st=w8z3lv8o&dl=1";
    name = "modpack.zip";
    extension = "zip";
    hash = "sha256-kNv/QO/VOm4/pMyFMA9yFgVIcoG8AkHBtTS7bBaJtdA=";
    stripRoot = false;
  };
  forgeServer = pkgs.callPackage ./forge-server.nix {};
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
      level-type = "skyblockbuilder:skyblock";
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
      "config/pcf-common.toml".value = {
        forwardingSecret = "@VELOCITY_FORWARDING_SECRET@";
      };
      defaultconfigs = "${modpack}/defaultconfigs";
    };
    symlinks =
      collectFilesAt modpack "mods"
      // {
        "server-icon.png" = "${modpack}/server-icon.png";
        "mods/proxy-compatible-forge" = pkgs.fetchurl rec {
          pname = "proxy-compatible-forge";
          version = "1.1.6";
          url = "https://github.com/adde0109/Proxy-Compatible-Forge/releases/download/1.1.6/${pname}-${version}.jar";
          hash = "sha256-wimwdYrRTm9anbpu9IPkssQyuBvoTgaSiBY/IZlYNrk=";
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
