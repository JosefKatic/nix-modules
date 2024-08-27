{inputs, ...}: {
  flake.homeManagerModules = {
    default = import ./user inputs;
  };
}
