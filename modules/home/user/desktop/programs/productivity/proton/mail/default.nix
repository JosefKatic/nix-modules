{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.user.desktop.programs.productivity.proton.mail;
in {
  options.user.desktop.programs.productivity.proton.mail = {
    enable = lib.mkEnableOption "Enable Proton Pass";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.protonmail-desktop
      pkgs.protonmail-bridge
    ];
  };
}
