{
  config,
  lib,
  pkgs,
  self,
  inputs,
  ...
}: {
  options = {
    user = {
      name = lib.mkOption {
        type = lib.types.str;
        example = "";
        description = "User name";
      };
    };
  };
  config = {
    nixpkgs = {
      overlays =
        builtins.attrValues inputs.self.overlays
        ++ [
          (final: prev: {
            lib =
              prev.lib
              // {
                colors = import "${self}/lib/colors" lib;
              };
          })
        ];
      config = {
        allowBroken = true;
        allowUnfree = true;
        allowUnfreePredicate = _: true;
        permittedInsecurePackages = [
          "electron-25.9.0"
        ];
      };
    };
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration = true;
    };

    nix = {
      package = lib.mkDefault pkgs.lix;
      settings = {
        experimental-features = ["nix-command" "flakes" "repl-flake"];
        warn-dirty = false;
      };
    };

    systemd.user.startServices = "sd-switch";

    programs = {
      home-manager.enable = true;
      git.enable = true;
    };

    home = {
      username = config.user.name;
      homeDirectory = lib.mkDefault "/home/${config.user.name}";
      stateVersion = lib.mkDefault "24.05";
      sessionPath = ["$HOME/.local/bin"];
      sessionVariables = {
        FLAKE = "$HOME/.nix-config";
      };
      packages = with pkgs; [
        # icon fonts
        material-symbols
        material-design-icons

        # Sans(Serif) fonts
        noto-fonts
        noto-fonts-cjk
        noto-fonts-emoji
        roboto
        dosis
        rubik
        (google-fonts.override {fonts = ["Inter"];})

        # monospace fonts
        jetbrains-mono
        # nerdfonts
        (nerdfonts.override {fonts = ["Iosevka" "FiraCode"];})
      ];

      persistence = {
        "/persist/home/${config.user.name}" = {
          directories = [
            "Documents"
            "Downloads"
            "Pictures"
            "Videos"
            "develop"
            ".local/bin"
            ".local/share/nix" # trusted settings and repl history
          ];
          allowOther = true;
        };
      };
    };
  };
}
