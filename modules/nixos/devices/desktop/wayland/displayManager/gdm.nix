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
    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;

    environment.etc."gdm/PostLogin/Default" = {
      text = ''
        set -e
        if [[ -d $HOME/${home.init.path} ]]; then
          echo "Path already exists, no need to clone. Update should update it"
          exit 1
	fi
        mkdir -p $HOME/${home.init.path}
        cd $HOME/${home.init.path}
        git init
        git remote add origin ${home.init.url}
        git pull origin main
        ${home.init.install}
      '';
      mode = "0755";
    };

    programs.dconf.profiles.gdm.databases = [
      {
        settings = {
          "org/gnome/login-screen" = {
            logo = "${logoFile}";
          };
        };
      }
    ];
  };
}
