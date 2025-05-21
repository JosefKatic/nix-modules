{
  config,
  lib,
  pkgs,
  ...
}: let
  gzipJson = {}: {
    generate = name: value:
      pkgs.callPackage (
        {
          runCommand,
          gzip,
        }:
          runCommand name
          {
            nativeBuildInputs = [gzip];
            value = builtins.toJSON value;
            passAsFile = ["value"];
          }
          ''
            gzip "$valuePath" -c > "$out"
          ''
      ) {};

    type = (pkgs.formats.json {}).type;
  };
in {
  config = lib.mkIf config.device.server.minecraft.enable {
    services.minecraft-servers.servers.proxy = rec {
      extraStartPost = ''
        echo 'lpv import initial.json.gz' > /run/minecraft/proxy.stdin
      '';
      extraReload = extraStartPost;

      symlinks = {
        "plugins/LuckPerms.jar" = let
          build = "1581";
        in
          pkgs.fetchurl rec {
            pname = "LuckPerms";
            version = "5.4.164";
            url = "https://download.luckperms.net/${build}/velocity/${pname}-Velocity-${version}.jar";
            hash = "sha256-A71QvcbkSQqyjpwpdeLxnebLFJ3UbovsIZkiZ1SkEH8=";
          };
        "plugins/luckperms/initial.json.gz".format = gzipJson {};
        "plugins/luckperms/initial.json.gz".value = let
          mkPermissions = lib.mapAttrsToList (key: value: {inherit key value;});
        in {
          groups = {
            owner.nodes = mkPermissions {
              "group.admin" = true;
              "prefix.1000.&5" = true;
              "weight.1000" = true;

              "librelogin.*" = true;
              "luckperms.*" = true;
              "velocity.command.*" = true;
            };
            admin.nodes = mkPermissions {
              "group.default" = true;
              "prefix.900.&6" = true;
              "weight.900" = true;

              "huskchat.command.broadcast" = true;
            };
            default.nodes = mkPermissions {
              "huskchat.command.channel" = true;
              "huskchat.command.msg" = true;
              "huskchat.command.msg.reply" = true;
            };
          };
          users = {
            "7f42900f-ea07-4a6b-9ee1-6a224f1843f6" = {
              username = "Pepik_CZ";
              nodes = mkPermissions {"group.owner" = true;};
            };
          };
        };
      };

      files = {
        "plugins/luckperms/config.yml".value = {
          server = "proxy";
          storage-method = "mysql";
          data = {
            address = "127.0.0.1";
            database = "minecraft";
            username = "minecraft";
            password = "@DATABASE_PASSWORD@";
            table-prefix = "luckperms_";
          };
          messaging-service = "sql";
        };
      };
    };
  };
}
