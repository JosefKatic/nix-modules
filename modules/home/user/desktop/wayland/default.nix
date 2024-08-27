inputs: {
  imports = let
    waybar = import ./waybar inputs;
    hyprland = import ./hyprland inputs;
  in [hyprland waybar];
}
