{
  config,
  lib,
  ...
}: {
  imports = [
    # ./servers/lobby
    ./servers/proxy
    ./servers/survival
    ./server.nix
  ];
}
