{inputs, ...}: {
  flake.nixosModules = {
    default = import ./devices inputs;
  };
}
