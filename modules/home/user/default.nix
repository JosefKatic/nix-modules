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
    inputs.anyrun.homeManagerModules.default
    inputs.impermanence.nixosModules.home-manager.impermanence
    inputs.matugen.nixosModules.default
    inputs.nix-index-db.hmModules.nix-index
    inputs.nur.nixosModules.nur
    inputs.sops-nix.homeManagerModules.sops
  ];
}
