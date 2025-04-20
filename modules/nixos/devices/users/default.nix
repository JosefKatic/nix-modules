{
  self,
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  inherit (config.networking) hostName;
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  options = {
    device.users = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          shell = lib.mkOption {
            type = lib.types.path;
            default = pkgs.fish;
          };
          extraGroups = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
            example = ["wheel"];
          };
        };
      });
      default = {};
    };
  };

  config = {
    users.mutableUsers = false;
    # BACKUP ACCOUNT IN CASE SSSD won't work
    users.users.admin = {
      isNormalUser = true;
      shell = pkgs.fish;
      uid = 1001;
      extraGroups =
        [
          "wheel"
          "video"
          "audio"
          "network"
          "i2c"
          "adbusers"
          "dialout"
        ]
        ++ ifTheyExist [
          "minecraft"
          "wireshark"
          "mysql"
          "docker"
          "podman"
          "git"
          "libvirtd"
          "deluge"
        ];
      openssh.authorizedKeys.keys = [(builtins.readFile "${self}/ssh.pub")];
      hashedPasswordFile = config.sops.secrets.admin-password.path;
    };
    users.users.root = {
      openssh.authorizedKeys.keys = [(builtins.readFile "${self}/ssh.pub")];
      hashedPasswordFile = config.sops.secrets.admin-password.path;
    };

    # Loop
    sops.secrets.admin-password = {
      sopsFile = "${self}/secrets/admin/secrets.yaml";
      neededForUsers = true;
    };
  };
}
