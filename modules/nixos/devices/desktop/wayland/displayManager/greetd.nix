{
  self,
  config,
  lib,
  pkgs,
  default,
  ...
}: let
  variant = config.theme.colorscheme.mode;
  cfg = config.device.desktop.wayland.displayManager.regreet;

  homeCfgs = config.home-manager.users;
  homeSharePaths = lib.mapAttrsToList (n: v: "${v.home.path}/share") homeCfgs;
  vars = ''
    XDG_DATA_DIRS="$XDG_DATA_DIRS:${lib.concatStringsSep ":" homeSharePaths}"'';

  gtkTheme = {
    name =
      if variant == "light"
      then "adw-gtk3"
      else "adw-gtk3-dark";
    package = "adw-gtk3";
  };
  iconTheme = {
    name = "Adwaita";
    package = "gnome.adwaita-icon-theme";
  };
  cursorTheme = {
    name = "Bibata-Modern-Classic";
    package = "bibata-cursors";
  };

  sway-kiosk = command: "${lib.getExe pkgs.sway} --unsupported-gpu --config ${
    pkgs.writeText "kiosk.config" ''
      output * bg #000000 solid_color
      xwayland disable
      input "type:touchpad" {
        tap enabled
      }
      exec 'WLR_NO_HARDWARE_CURSORS=1 GTK_USE_PORTAL=0 ${vars} ${command}; ${pkgs.sway}/bin/swaymsg exit'
    ''
  }";
in {
  options.device.desktop.wayland.displayManager.regreet = {
    enable =
      lib.mkEnableOption "Enable greetd as the display manager for wayland";
    themes = {
      gtk = {
        name = lib.mkOption {
          type = lib.types.str;
          default = gtkTheme.name;
        };
        package = lib.mkOption {
          type = lib.types.str;
          default = gtkTheme.package;
        };
      };
      icons = {
        name = lib.mkOption {
          type = lib.types.str;
          default = iconTheme.name;
        };
        package = lib.mkOption {
          type = lib.types.str;
          default = iconTheme.package;
        };
      };
      cursor = {
        name = lib.mkOption {
          type = lib.types.str;
          default = cursorTheme.name;
        };
        package = lib.mkOption {
          type = lib.types.str;
          default = cursorTheme.package;
        };
      };
    };
  };
  config = lib.mkIf cfg.enable {
    users.extraUsers.greeter = {
      packages = [
        pkgs.${gtkTheme.package}
        pkgs.${iconTheme.package}
        pkgs.${cursorTheme.package}
      ];
      # For caching and such
      home = "/tmp/greeter-home";
      createHome = true;
    };

    programs.regreet = {
      enable = true;
      settings = {
        GTK = {
          icon_theme_name = iconTheme.name;
          theme_name = gtkTheme.name;
          cursor_theme_name = cursorTheme.name;
        };
        background = {
          path = homeCfgs.joka.theme.wallpaper;
          fit = "Cover";
        };
      };
    };
    services.greetd = {
      enable = true;
      settings.default_session.command =
        sway-kiosk (lib.getExe config.programs.regreet.package);
    };
    security.pam.services.greetd.enableGnomeKeyring = true;
  };
}
