{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [./kdeconnect.nix ./virtualisation];
}
