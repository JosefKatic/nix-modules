inputs: let
  plugins = import ./plugins inputs;
  services = import ./services inputs;
in {
  imports = [./config ./hyprland.nix plugins services];
}
