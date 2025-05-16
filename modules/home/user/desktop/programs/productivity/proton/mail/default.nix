{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.user.desktop.programs.productivity.proton.mail;
  cfgHyprland = config.user.desktop.wayland.hyprland;
in {
  options.user.desktop.programs.productivity.proton.mail = {
    enable = lib.mkEnableOption "Enable Proton Pass";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.protonmail-desktop
      pkgs.protonmail-bridge
    ];

    wayland.windowManager.hyprland.settings = lib.mkIf cfgHyprland.enable {
      bind = [
        # Proton Mail
        "ALT, E, togglespecialworkspace, mail"
      ];
      exec-once = [
        "[workspace special:mail silent] proton-mail"
      ];
    };
  };
}
