inputs: {
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.user.desktop.programs.browsers;
in {
  options.user.desktop.programs.browsers.zen.enable =
    lib.mkEnableOption "Enable Zen browser";

  config = lib.mkIf cfg.chromium.enable {
    home.packages = [
      inputs.zen-browser.packages.${pkgs.system}.default
    ];
  };
}
