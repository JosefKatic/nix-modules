{
  config,
  pkgs,
  self,
  lib,
  ...
}:
# nix tooling
{
  home.packages = with pkgs; [
    alejandra
    deadnix
    statix
  ];
}
