inputs: let
  client = import ./client.nix inputs;
  server = import ./server.nix inputs;
in {
  imports = [client server];
}
