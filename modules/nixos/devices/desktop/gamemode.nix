{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.device.desktop;
  programs = lib.makeBinPath [
    config.programs.hyprland.package
    pkgs.coreutils
    # pkgs.power-profiles-daemon
  ];

  startscript = pkgs.writeShellScript "gamemode-start" ''
    export PATH=$PATH:${programs}
    export HYPRLAND_INSTANCE_SIGNATURE=$(ls -1 /tmp/hypr | tail -1)
    hyprctl --batch 'keyword decoration:blur 0 ; keyword animations:enabled 0 ; keyword misc:vfr 0'
    powerprofilesctl set performance
  '';

  endscript = pkgs.writeShellScript "gamemode-end" ''
    export PATH=$PATH:${programs}
    export HYPRLAND_INSTANCE_SIGNATURE=$(ls -1 /tmp/hypr | tail -1)
    hyprctl --batch 'keyword decoration:blur 1 ; keyword animations:enabled 1 ; keyword misc:vfr 1'
    powerprofilesctl set power-saver
  '';
in {
  options.device.desktop.gamemode = {
    enable = lib.mkEnableOption "Enable gamemode";
  };
  config = lib.mkIf cfg.gamemode.enable {
    programs.gamemode = {
      enable = true;
      settings = {
        general = {
          softrealtime = "auto";
          renice = 15;
        };
        custom = lib.mkIf cfg.wayland.windowManager.hyprland.enable {
          start = startscript.outPath;
          end = endscript.outPath;
        };
      };
    };
  };
}
