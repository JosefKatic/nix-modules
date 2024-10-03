{
  pkgs,
  self,
  inputs,
  lib,
  pythonAtLeast,
  ...
}: {
  environment.systemPackages = [
    pkgs.git
    pkgs.yubikey-manager-qt
    pkgs.libyubikey
    pkgs.ntfs3g
    pkgs.woeusb
    pkgs.portfolio
    pkgs.kitty
    pkgs.home-manager
  ];

  programs.nh = {
    enable = true;
    # weekly cleanup
    clean = {
      enable = true;
      extraArgs = "--keep 5 --keep-since 1w";
    };
  };

  nix = {
    package = pkgs.lix;
    settings = {
      builders-use-substitutes = true;
      substituters = [
        "https://anyrun.cachix.org"
        "https://hyprland.cachix.org"
      ];
      trusted-public-keys = [
        "anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
      trusted-users = ["root" "@wheel" "nix-ssh"];
      auto-optimise-store = lib.mkDefault true;
      experimental-features = ["nix-command" "flakes" "ca-derivations" "repl-flake"];
      warn-dirty = false;
      system-features = ["kvm" "big-parallel" "nixos-test"];
      flake-registry = "";

      # for direnv GC roots
      keep-derivations = true;
      keep-outputs = true;
    };
    # Add each flake input as a registry
    # To make nix3 commands consistent with the flake
    registry = lib.mapAttrs (_: value: {flake = value;}) inputs;

    # Add nixpkgs input to NIX_PATH
    # This lets nix2 commzands still use <nixpkgs>
    nixPath = ["nixpkgs=${inputs.nixpkgs.outPath}"];
    sshServe = {
      enable = true;
      keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMrMubi3ooI8JN1E3iGF+j51TwloMRnkUCXQWO6gIYCj nix-ssh"
      ];
      protocol = "ssh";
      write = true;
    };
  };
  nixpkgs = {
    overlays = [
      (final: prev: {
        inputs =
          builtins.mapAttrs (
            _: flake: let
              legacyPackages = (flake.legacyPackages or {}).${final.system} or {};
              packages = (flake.packages or {}).${final.system} or {};
            in
              if legacyPackages != {}
              then legacyPackages
              else packages
          )
          inputs;
      })
      (final: prev: {
        lib =
          prev.lib
          // {
            colors = import "${self}/lib/colors" prev.lib;
          };
      })
    ];
    config = {
      allowBroken = true;
      allowUnfree = true;
      permittedInsecurePackages = [
        "electron-25.9.0"
      ];
    };
  };
}
