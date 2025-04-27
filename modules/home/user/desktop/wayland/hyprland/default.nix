inputs: let
  hyprland = import ./hyprland.nix inputs;
  services = import ./services inputs;
in {
  imports = [./config hyprland ./plugins services];
}
