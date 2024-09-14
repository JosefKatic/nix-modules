inputs: {
  imports = let
    windowManager = import ./windowManager inputs;
    displayManager = import ./displayManager inputs;
  in [./desktopManager displayManager windowManager];
}
