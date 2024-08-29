inputs: {
  config,
  lib,
  ...
}: {
  imports = let
    proxy = import ./servers/proxy inputs;
    survival = import ./servers/survival inputs;
  in [
    # ./servers/lobby
    proxy
    survival
    ./server.nix
  ];
}
