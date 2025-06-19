{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.device.desktop.wayland.desktopManager;
in {
  options.device.desktop.wayland.desktopManager = {
    gnome = {enable = lib.mkEnableOption "Enable Gnome";};
    plasma6 = {enable = lib.mkEnableOption "Enable Plasma6";};
  };

  config = {
    services.desktopManager.gnome.enable = cfg.gnome.enable;

    # Taken from https://hoverbear.org/blog/declarative-gnome-configuration-in-nixos/
    # Most of the excluded packages are replaced by alternatives in home config
    environment.gnome.excludePackages =
      (with pkgs; [
        gnome-photos
        gnome-tour
        gedit
      ])
      ++ (with pkgs.gnome; [
        cheese # webcam tool
        gnome-music
        epiphany # web browser
        geary # email reader
        gnome-characters
        tali # poker game
        iagno # go game
        hitori # sudoku game
        atomix # puzzle game
        yelp # Help view
        gnome-contacts
        gnome-initial-setup
      ]);
    environment.systemPackages = with pkgs;
      lib.optionals (cfg.gnome.enable) [
        gnome.gnome-tweaks
      ];

    services.desktopManager.plasma6.enable = cfg.plasma6.enable;
    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      plasma-browser-integration
      konsole
      oxygen
    ];
  };
}
