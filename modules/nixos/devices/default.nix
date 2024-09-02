inputs: {
  self,
  config,
  lib,
  options,
  pkgs,
  ...
}: {
  home-manager = {
    # useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
  };
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
    ./boot
    ./core
    ./hardware
    ./utils
    ./users
    desktop
    server
  ];
}
