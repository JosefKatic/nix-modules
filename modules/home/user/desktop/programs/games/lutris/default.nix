{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.user.desktop.programs.games.lutris;
  monitor = lib.head (lib.filter (m: m.primary) config.user.desktop.monitors);
  steam-session =
    pkgs.writeTextDir "share/wayland-sessions/steam-sesson.desktop"
    /*
    ini
    */
    ''
      [Desktop Entry]
      Name=Steam Session
      Exec=${pkgs.gamescope}/bin/gamescope -W ${toString monitor.width} -H ${toString monitor.height} -O ${monitor.name} -e -- steam -gamepadui
      Type=Application
    '';
  steam-with-pkgs = pkgs.steam.override {
    extraPkgs = pkgs:
      with pkgs; [
        xorg.libXcursor
        xorg.libXi
        xorg.libXinerama
        xorg.libXScrnSaver
        libpng
        libpulseaudio
        libvorbis
        stdenv.cc.cc.lib
        libkrb5
        keyutils
        gamescope
        mangohud
      ];
  };
in {
  options.user.desktop.programs.games.lutris.enable = lib.mkEnableOption "Enable Minecraft";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      (lutris.override
        {
          extraPkgs = p: [
            p.wineWowPackages.staging
            p.pixman
            p.libjpeg
            p.zenity
          ];
        })
      steam-with-pkgs
      steam-session
      gamescope
      mangohud
      protontricks
      winetricks
    ];
  };
}
