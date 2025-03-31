{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [./kdeconnect.nix ./proton ./virtualisation];
}
