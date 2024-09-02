inputs: {
  imports = let
    anyrun = import ./anyrun inputs;
    hyprpaper = import ./hyprpaper inputs;
  in [anyrun ./hypridle ./hyprlock hyprpaper];
}
