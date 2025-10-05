inputs: {
  self,
  lib,
  ...
}: {
  imports = let
    theme = import ./theme inputs;
    desktop = import ./desktop inputs;
  in [
    ./core.nix
    ./services
    ./terminal
    desktop
    theme
    inputs.impermanence.nixosModules.home-manager.impermanence
    inputs.matugen.nixosModules.default
    inputs.nix-index-db.homeModules.nix-index
    inputs.nur.modules.homeManager.default
    inputs.sops-nix.homeManagerModules.sops
  ];
}
