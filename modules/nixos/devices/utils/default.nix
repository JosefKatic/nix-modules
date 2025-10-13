{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [./kdeconnect.nix ./opendrop ./virtualisation];
}
