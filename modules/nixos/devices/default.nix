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
  imports = [
    inputs.hm.nixosModule
    inputs.hyprland.nixosModules.default
    inputs.nix-gaming.nixosModules.pipewireLowLatency
    inputs.nix-minecraft.nixosModules.minecraft-servers
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.sops-nix.nixosModules.sops
    inputs.impermanence.nixosModules.impermanence
    ./boot
    ./core
    ./hardware
    ./desktop
    ./utils
    ./users
    ./server
  ];
}
