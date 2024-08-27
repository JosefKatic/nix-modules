{
  config,
  lib,
  options,
  pkgs,
  ...
}: {
  documentation.dev.enable = true;
  hardware.graphics.enable = true;
  imports = [
    ./build.nix
    ./storage
    ./locale.nix
    ./network.nix
    ./nix.nix
    ./kernel.nix
    ./no-defaults.nix
    ./openssh.nix
    ./power.nix
    ./security.nix
    ./shells
    ./sops.nix
    ./sound.nix
    ./specialisations.nix
  ];

  # These are configs that needs to be everywhere
  hardware.enableRedistributableFirmware = true;
  # DON"T CHANGE THIS!
  system.stateVersion = lib.mkDefault "24.05";
}
