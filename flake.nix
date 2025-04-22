{
  description = "Flake with modules for joka00.dev";

  nixConfig = {
    extra-substituters = [
      "https://hyprland.cachix.org"
    ];
    extra-trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    hardware.url = "github:nixos/nixos-hardware";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
    nix-colors.url = "github:misterio77/nix-colors";
    systems.url = "github:nix-systems/default-linux";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    hm = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Tools
    lanzaboote.url = "github:nix-community/lanzaboote";

    impermanence.url = "github:nix-community/impermanence";

    nix-index-db = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-configurator-api = {
      url = "github:JosefKatic/nix-configurator-api";
    };
    nix-configurator-web = {
      url = "github:JosefKatic/nix-configurator-web";
    };
    nix-gaming.url = "github:fufexan/nix-gaming";

    nh = {
      url = "github:viperML/nh";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    matugen = {
      url = "github:InioX/Matugen";
    };
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    hyprpaper = {
      url = "github:hyprwm/hyprpaper";
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Programs
    anyrun = {
      url = "github:anyrun-org/anyrun";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprsplit = {
      url = "github:shezdy/hyprsplit";
      inputs.hyprland.follows = "hyprland";
    };
    # NUR
    nur.url = "github:nix-community/NUR";

    helix = {
      url = "github:SoraTenshi/helix/new-daily-driver";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
    };
    web.url = "github:JosefKatic/web";

    zen-browser.url = "github:youwen5/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = {
    self,
    nixpkgs,
    flake-parts,
    systems,
    nix-colors,
    nur,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux"];
      perSystem = {system, ...}: {
        _module.args.pkgs = import nixpkgs {
          inherit system;
          overlays = [
            inputs.self.overlays.joka00-modules
            inputs.self.overlays.patchFreeIPA
            nur.overlays.default
          ];
        };
      };
      imports = [
        ./.hydra
        ./shell.nix
        ./packages
        ./overlays
        ./modules
        ./pre-commit-hooks.nix
      ];
    };
}
