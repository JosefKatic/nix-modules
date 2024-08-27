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
    users.mutableUsers = false;
    # Loop

    # users.users.deploy = {
    #   isNormalUser = true;
    #   extraGroups = ["wheel"];
    #   useDefaultShell = true;
    #   home = "/tmp/deploy";
    #   createHome = true;
    #   hashedPasswordFile = config.sops.secrets.joka-password.path;
    #   openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEdTMV//NJlgA7P87ZoIuk6PZHZDgYfODJck0wZmRqWV deploy"];
    # };
    # users.extraUsers.nix-deploy = {
    #   isNormalUser = true;
    #   shell = pkgs.bash;
    #   group = "nix-deploy";
    #   extraGroups = [
    #     "wheel"
    #   ];
    #   home = "/.deploy";
    #   hashedPasswordFile = config.sops.secrets.joka-password.path;
    #   openssh.authorizedKeys.keys = [(builtins.readFile "${self}/home/joka/ssh.pub")];
    # };

    security.sudo.extraRules = [
      {
        users = ["deploy"];
        commands = [
          # {
          #   command = lib.getExe pkgs.deploySystem;
          #   options = ["NOSETENV" "NOPASSWD"];
          # }
          {
            command = "/run/current-system/sw/bin/nixos-rebuild";
            options = ["NOSETENV" "NOPASSWD"];
          }
          {
            command = "/run/current-system/bin/switch-to-configuration";
            options = ["NOSETENV" "NOPASSWD"];
          }
        ];
      }
    ];

    users.groups.nix-deploy = {};
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
      # openssh.authorizedKeys.keys = [(builtins.readFile "${self}/home/${username}/ssh.pub")];
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
