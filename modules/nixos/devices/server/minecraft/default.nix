inputs: {
  config,
  lib,
  ...
}: {
  imports = let
    # proxy = import ./servers/proxy inputs;
    # survival = import ./servers/survival inputs;
    modpack = import ./servers/modpack inputs;
  in [
    # proxy
    # survival
    modpack
    # ./servers/limbo
    ./server.nix
  ];
}
