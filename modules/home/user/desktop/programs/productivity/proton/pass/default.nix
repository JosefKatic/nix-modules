{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.user.desktop.programs.productivity.proton.pass;
in {
  options.user.desktop.programs.productivity.proton.pass = {
    enable = lib.mkEnableOption "Enable Proton Pass";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.proton-pass
    ];
  };
}
