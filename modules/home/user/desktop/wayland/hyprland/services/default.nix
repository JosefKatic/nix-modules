inputs: {
  imports = let
    hyprpaper = import ./hyprpaper inputs;
  in [./anyrun ./hypridle ./hyprlock hyprpaper ./vnc];
}
