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
        experimental-features = ["nix-command" "flakes"];
        warn-dirty = false;
      };
    };

    systemd.user.startServices = "sd-switch";

    programs = {
      git.enable = true;
    };

    fonts.fontconfig = {
      enable = true;
      defaultFonts = {
        serif = ["Noto Serif" "Noto Color Emoji"];
        sansSerif = ["Noto Sans" "Noto Color Emoji"];
        monospace = ["Fira Code" "JetBrains Mono" "" "Noto Color Emoji"];
        emoji = ["Noto Color Emoji"];
      };
    };

    home = {
      username = config.user.name;
      homeDirectory = lib.mkDefault "/home/${config.user.name}";
      stateVersion = lib.mkDefault "24.05";
      sessionPath = ["$HOME/.local/bin"];
      sessionVariables = {
        FLAKE = "$HOME/.nix-config";
        NH_FLAKE = "$HOME/.nix-config";
      };
      packages = with pkgs; [
        # icon fonts
        material-symbols
        material-design-icons

        # Sans(Serif) fonts
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-emoji
        fira-code
        inter
        roboto
        dosis
        rubik
        (google-fonts.override {fonts = ["Inter"];})

        # monospace fonts
        jetbrains-mono
        # nerdfonts
        nerd-fonts.iosevka
        nerd-fonts.fira-code
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
