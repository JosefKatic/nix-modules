{
  config,
  lib,
  pkgs,
  utils,
  ...
}: let
  inherit (config.device) home;
  inherit (lib) types mkOption mkMerge optional;
in {
  options.device.home = {
    users = mkOption {
      type = types.listOf types.str;
    };
    init = {
      url = mkOption {
        type = types.str;
        default = "https://github.com/JosefKatic/nix-config.git";
        description = "Link to repository";
      };
      path = mkOption {
        type = types.str;
        default = ".config/.nix-config";
        description = "Clone path for configuration repository, relative to user's $HOME";
      };
      install = mkOption {
        type = types.str;
        default = "./install";
        description = "Installation command";
      };
    };
  };

  config = let
    check = user: "home-config-check-${user}";
    initialise = user: "home-config-initialise-${user}";
    service = unit: "${unit}.service";
  in {
    # set up user configuration *before* first login
    systemd.services = mkMerge (map (user: {
        # skip initialisation early on boot, before waiting for the network, if
        # git repository appears to be in place.
        "${check user}" = {
          description = "check home configuration for ${user}";
          wantedBy = ["multi-user.target"];
          unitConfig = {
            # path must be absolute!
            # <https://www.freedesktop.org/software/systemd/man/systemd.unit.html#ConditionArchitecture=>
            ConditionPathExists = "!/home/${user}/${home.init.path}/.git";
          };
          serviceConfig = {
            User = user;
            SyslogIdentifier = check user;
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = "${pkgs.coreutils}/bin/true";
          };
        };
        "${initialise user}" = {
          description = "initialise home-manager configuration for ${user}";
          # do not allow login before setup is finished. after first boot the
          # process takes a long time, and the user would log into a broken
          # environment.
          # let display manager wait in graphical setups.
          wantedBy = ["multi-user.target"];
          before = ["systemd-user-sessions.service"] ++ optional config.services.xserver.enable "display-manager.service";
          # `nix-daemon` and `network-online` are required under the assumption
          # that installation performs `nix` operations and those usually need to
          # fetch remote data
          after = [(service (check user)) "nix-daemon.socket" "network-online.target"];
          bindsTo = [(service (check user)) "nix-daemon.socket" "network-online.target"];
          path = with pkgs; [git nix];
          environment = {
            NIX_PATH = builtins.concatStringsSep ":" config.nix.nixPath;
          };
          serviceConfig = {
            User = user;
            Type = "oneshot";
            SyslogIdentifier = initialise user;
            ExecStart = let
              script = pkgs.writeShellScriptBin (initialise user) ''
                set -e
                mkdir -p /home/${user}/${home.init.path}
                cd /home/${user}/${home.init.path}
                git init
                git remote add origin ${home.init.url}
                git pull origin main
                ${home.init.install}
              '';
            in "${script}/bin/${initialise user}";
          };
        };
      })
      home.users);
  };
}
