{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [./auto-upgrade.nix ./kdeconnect.nix ./virtualisation];
}
