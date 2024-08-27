{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.user.desktop.services;
  inherit (config.theme.colorscheme) colors mode;
in {
  options.user.desktop.services.mako = {
    enable = lib.mkEnableOption "Enable Mako notifications";
  };

  config = lib.mkIf cfg.mako.enable {
    services.mako = {
      enable = true;
      iconPath =
        if mode == "dark"
        then "${config.gtk.iconTheme.package}/share/icons/Papirus-Dark"
        else "${config.gtk.iconTheme.package}/share/icons/Papirus-Light";
      font = "Fira Sans 12";
      padding = "10,20";
      anchor = "top-center";
      width = 400;
      height = 150;
      borderSize = 0;
      defaultTimeout = 12000;
      backgroundColor = "${colors.surface}dd";
      textColor = "${colors.on_surface}dd";
      layer = "overlay";
    };
  };
}
