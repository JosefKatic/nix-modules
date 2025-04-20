inputs: {
  imports = let
    hosting = import ./hosting inputs;
    minecraft = import ./minecraft inputs;
    nixConfigurator = import ./nix-configurator inputs;
  in [
    ./auth
    ./cache
    ./databases
    ./git
    ./homelab
    hosting
    ./hydra
    minecraft
    ./services
    ./teamspeak
    nixConfigurator
  ];
}
