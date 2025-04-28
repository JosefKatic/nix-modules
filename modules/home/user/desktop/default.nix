inputs: {
  imports = let
    programs = import ./programs inputs;
    wayland = import ./wayland inputs;
  in [
    programs
    ./services
    ./monitors.nix
    ./gtk.nix
    wayland
    ./qt.nix
  ];
}
