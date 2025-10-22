inputs: {
  self,
  config,
  lib,
  options,
  pkgs,
  ...
}: {
  imports = let
    server = import ./server inputs;
  in [
    inputs.hm.nixosModules.home-manager
    inputs.nix-gaming.nixosModules.pipewireLowLatency
    inputs.nix-minecraft.nixosModules.minecraft-servers
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.sops-nix.nixosModules.sops
    inputs.impermanence.nixosModules.impermanence
    inputs.nix-configurator-api.nixosModules.default
    inputs.authentik-nix.nixosModules.default
    ./boot
    ./core
    ./desktop
    ./home
    ./hardware
    ./utils
    ./users
    server
  ];
}
