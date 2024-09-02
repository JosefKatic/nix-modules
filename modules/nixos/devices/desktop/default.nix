inputs: {
  imports = let
    wayland = import ./wayland inputs;
  in [./gamemode.nix wayland];
}
