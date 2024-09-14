inputs: {
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
    systemd.user.services.home-manager-init = {
      after = ["graphical-session.target"];
      bindsTo = ["graphical-session.target" "nix-daemon.socket" "network-online.target"];
      wantedBy = ["graphical-session.target"];
      wants = ["nix-daemon.socket" "network-online.target"];
      path = with pkgs; [git nix coreutils] ++ [inputs.hm.packages.${pkgs.system}.default];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = false;
        ExecStart = let
          systemctl = "XDG_RUNTIME_DIR=\${XDG_RUNTIME_DIR:-/run/user/$UID} systemctl";

          sed = "${pkgs.gnused}/bin/sed";

          exportedSystemdVariables = builtins.concatStringsSep "|" [
            "DBUS_SESSION_BUS_ADDRESS"
            "DISPLAY"
            "WAYLAND_DISPLAY"
            "XAUTHORITY"
            "XDG_RUNTIME_DIR"
          ];

          setupEnv = pkgs.writeScript "hm-user-setup" ''
            #! ${pkgs.runtimeShell} -el
            # The activation script is run by a login shell to make sure
            # that the user is given a sane environment.
            # If the user is logged in, import variables from their current
            # session environment.
            eval "$(
              ${systemctl} --user show-environment 2> /dev/null \
              | ${sed} -En '/^(${exportedSystemdVariables})=/s/^/export /p'
            )"

            if [[ -d $HOME/${home.init.path} ]]; then
              echo "Path already exists, no need to clone. Update should update it"
              exit 0
            fi
            echo $USER
            echo $HOME
            mkdir -p $HOME/${home.init.path}
            cd $HOME/${home.init.path}
            git init
            git remote add origin ${home.init.url}
            git pull origin main
            current=$(dirname $(readlink --canonicalize-existing $0))
            hostname=$(cat /etc/hostname)
            if [[ ! -d $current/config/home/$hostname ]]; then
                echo "No config for this machine:"
                for i in $(ls -d $current/config/home/\*); do
                    echo $(basename $i)
                done
                exit 0
            fi

            if [[ ! -d $current/config/home/$hostname/$USER ]]; then
                echo "User doesn't have config for this device:"
                for i in $(ls -d $current/config/home/$hostname/\*); do
                    echo $(basename $i)
                done
                exit 0
            fi
            shift
            ${pkgs.coreutils}/bin/yes y | ${inputs.hm.packages.${pkgs.system}.default}/bin/home-manager switch -b backup --flake .
          '';
        in "${setupEnv}";
      };
    };

    programs.dconf.profiles.gdm.databases = [
      {
        settings = {
          "org/gnome/login-screen" = {
            logo = "${logoFile}";
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
