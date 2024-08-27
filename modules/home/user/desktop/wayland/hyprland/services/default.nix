inputs: {
  imports = let
    anyrun = import ./anyrun inputs;
  in [anyrun ./hypridle ./hyprlock ./hyprpaper];
}
