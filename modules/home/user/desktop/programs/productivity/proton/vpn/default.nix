{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.user.desktop.programs.productivity.proton.vpn;
in {
  options.user.desktop.programs.productivity.proton.vpn.enable = lib.mkEnableOption "Enable Proton VPN";

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.protonvpn-gui
    ];
  };
}
