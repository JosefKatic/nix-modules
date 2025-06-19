inputs: {
  imports = let
    hyprland = import ./hyprland inputs;
    quickshell = import ./quickshell inputs;
    waybar = import ./waybar inputs;
  in [hyprland quickshell waybar];
}
