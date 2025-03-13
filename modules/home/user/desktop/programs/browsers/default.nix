inputs: {
  config,
  lib,
  ...
}: let
  firefox = import ./firefox inputs;
  zen = import ./zen inputs;
in {
  imports = [./defaultBrowser.nix ./brave ./chromium firefox zen];
}
