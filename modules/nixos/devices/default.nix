inputs: {
  self,
  config,
  lib,
  options,
  pkgs,
  ...
}: {
  imports = let
    desktop = import ./desktop inputs;
    server = import ./server inputs;
  in [
    inputs.hm.nixosModule
    inputs.nix-gaming.nixosModules.pipewireLowLatency
    inputs.nix-minecraft.nixosModules.minecraft-servers
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.sops-nix.nixosModules.sops
    inputs.impermanence.nixosModules.impermanence
    inputs.nix-configurator-api.nixosModules.default
    ./boot
    ./core
    ./home
    ./hardware
    ./utils
    ./users
    desktop
    server
  ];
}
