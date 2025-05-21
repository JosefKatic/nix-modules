{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mapAttrs' replaceStrings nameValuePair;
in {
  config = lib.mkIf config.device.server.minecraft.enable {
    services.minecraft-servers.servers.proxy = {
      extraReload = ''
        echo 'librelogin reload configuration' > /run/minecraft/proxy.stdin
        echo 'librelogin reload messages' > /run/minecraft/proxy.stdin
      '';
      symlinks."plugins/LibreLogin.jar" = pkgs.fetchurl rec {
        pname = "LibreLogin";
        version = "0.23.0";
        url = "https://github.com/kyngs/${pname}/releases/download/${version}/${pname}.jar";
        hash = "sha256-KpdBl1SN0Mm79jYuN8GsJudZga73duDHkiHDqSl7JKw=";
      };
      files = {
        "plugins/librelogin/config.conf".format = pkgs.formats.json {};
        "plugins/librelogin/config.conf".value = {
          allowed-commands-while-unauthorized = [
            "login"
            "register"
            "2fa"
            "2faconfirm"
          ];
          auto-register = false;
          database = {
            database = "minecraft";
            host = "localhost";
            max-life-time = 600000;
            password = "@DATABASE_PASSWORD@";
            port = 3306;
            user = "minecraft";
          };
          debug = false;
          default-crypto-provider = "BCrypt-2A";
          fallback = false;
          kick-on-wrong-password = false;
          limbo = ["auth"];
          migration = {};
          milliseconds-to-refresh-notification = 10000;
          minimum-password-length = -1;
          new-uuid-creator = "MOJANG";
          # Use the same config as velocity's "try" and "forced-hosts
          pass-through = let
            velocityCfg = config.services.minecraft-servers.servers.proxy.files."velocity.toml".value;
          in
            {
              root = velocityCfg.servers.try;
            }
            // (mapAttrs' (n: nameValuePair (replaceStrings ["."] ["§"] n)) velocityCfg.forced-hosts);
          ping-servers = true;
          remember-last-server = true;
          revision = 3;
          seconds-to-authorize = -1;
          session-timeout = 604800;
          totp.enabled = true;
          use-titles = false;
        };
      };
    };
  };
}
