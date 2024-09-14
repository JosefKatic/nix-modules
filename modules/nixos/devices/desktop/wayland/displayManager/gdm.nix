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

    # environment.etc."gdm/PostLogin" = {
    #    text = ''
    #       #! /run/current-system/sw/bin/bash
    #	set -e
    #	set -x
    # exec 3>&1 4>&2
    # trap 'exec 2>&4 1&3' 0 1 2 3
    # exec 1>/var/log/gdm/PostLogin.log 2>&1
    # if [[ -d $HOME/${home.init.path} ]]; then
    # echo "Path already exists, no need to clone. Update should update it"
    #  exit 0
    # fi
    # ${pkgs.coreutils}/bin/rm -rf $HOME/.config/fish
    #  ${pkgs.coreutils}/bin/mkdir -p $HOME/${home.init.path}
    #  cd $HOME/${home.init.path}
    #   ${pkgs.git}/bin/git init
    #   ${pkgs.git}/bin/git remote add origin ${home.init.url}
    #    ${pkgs.git}/bin/git pull origin main
    #     ${pkgs.coreutils}/bin/yes y | ${pkgs.home-manager}/bin/home-manager switch -b backup --flake .
    #      exit 0
    #    '';
    #     mode = "0777";
    #    };
    # environment.etc."gdm/PostLogin/Default" = {
    #   text = ''
    #     if [[ -d $HOME/${home.init.path} ]]; then
    #       echo "Path already exists, no need to clone. Update should update it" >> $HOME/gdm.log
    #       exit 0
    #     fi
    #     rm -rf $HOME/.config/\*
    #     mkdir -p $HOME/${home.init.path}
    #     cd $HOME/${home.init.path}
    #     echo "Folder created, cloning repository" >> $HOME/gdm.log
    #     git init >> $HOME/gdm.log
    #     git remote add origin ${home.init.url} >> $HOME/gdm.log
    #     git pull origin main >> $HOME/gdm.log
    #     echo "Repository cloned, installing" >> $HOME/gdm.log
    #     exit 0
    #   '';
    #   mode = "0777";
    # };

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
