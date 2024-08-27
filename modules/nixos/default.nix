{inputs, ...}: {
  flake.nixosModules = {
    default = import ./devices inputs;
    nordvpn = import ./nordvpn.nix;
  };
}
