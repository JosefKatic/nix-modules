inputs: {
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with inputs; [
    quickshell.packages.${pkgs.system}.default
  ];
}
