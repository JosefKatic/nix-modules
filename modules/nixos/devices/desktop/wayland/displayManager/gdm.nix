{
  self,
  config,
  lib,
  options,
  pkgs,
  ...
}: let
  inherit (config.device) home;
  cfg = config.device.desktop.wayland.displayManager.gdm;
  logoFile = pkgs.fetchurl {
    url = "https://joka00.dev/assets/logo__dark.svg";
    sha256 = "1xd5hfxlh0m5687mfxndyv18a2k6aq7njna4n5smn7f7ynal1i28";
  };
in {
  options.device.desktop.wayland.displayManager.gdm = {
    enable = lib.mkEnableOption "Enable GDM";
  };

  config = lib.mkIf cfg.enable {
    environment.persistence = lib.mkIf config.device.core.storage.enablePersistence {
      "/persist" = {
        directories = ["/var/lib/AccountsService"];
      };
    };
    services.xserver.enable = true;
    services.displayManager.gdm = {
      enable = true;
      settings = {
        greeter.IncludeAll = false;
      };
    };

    programs.dconf.profiles.gdm.databases = [
      {
        settings = {
          "org/gnome/login-screen" = {
            logo = "${logoFile}";
            disable-user-list = true;
          };
          "org/gnome/desktop/background" = {
            picture-uri = "";
            picture-uri-dark = "";
            primary-color = "#111111";
            secondary-color = "#FFFFFF";
          };
        };
      }
    ];
  };
}
