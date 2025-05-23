inputs: {pkgs, ...}: let
  inherit (inputs.nix-minecraft.lib) collectFilesAt;
  modpack = pkgs.fetchzip {
    url = "https://www.dropbox.com/scl/fi/lj7j77yt851h5vkq9ezln/modpack.zip?rlkey=xxoqjorlxuv04an7mznqavv8i&st=iz256o9y&dl=1";
    name = "create-and-explore";
    extension = "zip";
    hash = "sha256-9PBKETqcE3iMbZEPCgMS2ZFWusxrW3ppO5MH10Ld7Kk=";
    stripRoot = false;
  };
  fabricServer = inputs.nix-minecraft.legacyPackages.${pkgs.system}.fabricServers.fabric-1_20_1.override {loaderVersion = "0.15.6";};
in {
  services.minecraft-servers.servers.modpack = {
    enable = true;
    enableReload = true;
    package = fabricServer;
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
      global_packs = "${modpack}/global_packs";
      defaultconfigs = "${modpack}/defaultconfigs";
    };
    symlinks =
      collectFilesAt modpack "mods"
      // {
        resourcepacks = "${modpack}/resourcepacks";
        shaderpacks = "${modpack}/shaderpacks";
        "mods/towns-and-towers.jar" = pkgs.fetchurl {
          url = "https://cdn.modrinth.com/data/DjLobEOy/versions/7ZwnSrVW/Towns-and-Towers-1.12-Fabric%2BForge.jar";
          name = "towns-and-towers";
          extension = "jar";
          hash = "sha256-nIEVr3EJV52pkCSf3WezgyOkW+cPijqWK2HaaccCGYQ='";
        };
        "mods/tectonic.jar" = pkgs.fetchurl {
          url = "https://cdn.modrinth.com/data/lWDHr9jE/versions/SWDOp7uu/tectonic-3.0.0%2Bbeta4.jar";
          name = "tectonic-3.0.0.beta4";
          extension = "jar";
          hash = "sha256-4IOczEPzaviDGZTlnA29ohRDsNI3j/bDRnEIx5C3cG4=";
        };
        "mods/terralith.jar" = pkgs.fetchurl {
          url = "https://cdn.modrinth.com/data/8oi3bsk5/versions/WeYhEb5d/Terralith_1.20.x_v2.5.4.jar";
          name = "terralith_v2.5.4";
          extension = "jar";
          hash = "ha256-j2XzCdjycjdUv0tgx7V2PTq27QSwHBchCbplZOmBuV8=";
        };
      };
  };
}
