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
  username = "joka";
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
    users.mutableUsers = true;

    users.users.${username} = {
      isNormalUser = true;
      shell = pkgs.fish;
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
          "nordvpn"
          "docker"
          "podman"
          "git"
          "libvirtd"
          "deluge"
        ];
      openssh.authorizedKeys.keys = [(builtins.readFile "${self}/ssh.pub")];
      hashedPasswordFile = config.sops.secrets.joka-password.path;
      packages = [
        pkgs.home-manager
      ];
    };

    # Loop
    sops.secrets.joka-password = {
      sopsFile = "${self}/secrets/${username}/secrets.yaml";
      neededForUsers = true;
    };
  };
}
