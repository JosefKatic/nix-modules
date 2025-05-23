inputs: {pkgs, ...}: let
  inherit (inputs.nix-minecraft.lib) collectFilesAt;
  modpack = pkgs.fetchzip {
    url = "https://www.dropbox.com/scl/fi/lj7j77yt851h5vkq9ezln/modpack.zip?rlkey=xxoqjorlxuv04an7mznqavv8i&st=tlrbli9z&dl=1";
    hash = "sha256-nxU7SLWrIxZBvZaLNFesjPZFU9fHWnoWPob7oqULLMQ=";
    name = "modpack";
    extension = "zip";
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
    };
    symlinks =
      collectFilesAt modpack "mods"
      // {
        global_packs = "${modpack}/global_packs";
        resourcepacks = "${modpack}/resourcepacks";
        shaderpacks = "${modpack}/shaderpacks";
        "mods/towns-and-towers.jar" = pkgs.fetchurl {
          url = "https://cdn.modrinth.com/data/DjLobEOy/versions/7ZwnSrVW/Towns-and-Towers-1.12-Fabric%2BForge.jar";
          name = "towns-and-towers";
          hash = "sha256-nIEVr3EJV52pkCSf3WezgyOkW+cPijqWK2HaaccCGYQ='";
        };
      };
  };
}
