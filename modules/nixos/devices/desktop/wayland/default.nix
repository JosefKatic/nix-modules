inputs: {
  imports = let
    windowManager = import ./windowManager inputs;
  in [./desktopManager ./displayManager windowManager];
}
