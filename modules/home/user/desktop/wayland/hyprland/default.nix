inputs: let
  hyprland = import ./hyprland.nix inputs;
  plugins = import ./plugins inputs;
  services = import ./services inputs;
in {
  imports = [./config hyprland plugins services];
}
