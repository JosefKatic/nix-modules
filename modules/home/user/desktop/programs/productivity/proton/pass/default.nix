{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.user.desktop.programs.productivity.proton.pass;
  cfgHyprland = config.user.desktop.wayland.hyprland;
in {
  options.user.desktop.programs.productivity.proton.pass = {
    enable = lib.mkEnableOption "Enable Proton Pass";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.proton-pass
    ];

    wayland.windowManager.hyprland.settings = lib.mkIf cfgHyprland.enable {
      bind = [
        # Proton Mail
        "ALT, P, togglespecialworkspace, pass"
      ];
      exec-once = [
        "[workspace special:pass silent] proton-pass"
      ];
    };
  };
}
