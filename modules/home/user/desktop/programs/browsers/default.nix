inputs: {
  config,
  lib,
  ...
}: let
  firefox = import ./firefox inputs;
in {
  imports = [./defaultBrowser.nix firefox ./brave ./chromium];
}
