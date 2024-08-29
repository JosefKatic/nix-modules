inputs: {
  imports = let
    hosting = import ./hosting inputs;
    minecraft = import ./minecraft inputs;
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
  ];
}
