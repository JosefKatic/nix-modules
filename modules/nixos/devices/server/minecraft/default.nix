inputs: {
  config,
  lib,
  ...
}: {
  imports = let
    proxy = import ./servers/proxy inputs;
    # survival = import ./servers/survival inputs;
    modpack = import ./servers/modpack inputs;
  in [
    proxy
    # survival
    modpack
    limbo
    ./server.nix
  ];
}
