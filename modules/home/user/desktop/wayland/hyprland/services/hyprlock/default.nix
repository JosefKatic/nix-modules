{
  config,
  lib,
  ...
}: let
  inherit (config.theme.colorscheme) colors;
  font_family = "Inter";
  cfg = config.user.desktop.wayland.hyprland.services.hyprlock;
in {
  options.user.desktop.wayland.hyprland.services.hyprlock.enable = lib.mkEnableOption "Enable Hyprlock";

  config = lib.mkIf cfg.enable {
    programs.hyprlock = {
      enable = true;
      settings = {
        general = {
          disable_loading_bar = true;
          hide_cursor = false;
          no_fade_in = true;
          grace = 15;
        };

        background = [
          {
            monitor = "";
            path = config.theme.wallpaper;
          }
        ];

        input-field = [
          {
            monitor = builtins.head (builtins.map (m: m.name) (builtins.filter (m: m.primary) config.user.desktop.monitors));

            size = "300, 50";
            outline_thickness = 2;

            outer_color = "rgb(${lib.removePrefix "#" colors.primary})";
            inner_color = "rgb(${lib.removePrefix "#" colors.primary_container})";
            font_color = "rgb(${lib.removePrefix "#" colors.on_primary_container})";
            placeholder_text = ''<span font_family="${font_family}" foreground="#${colors.on_primary_container}">Enter your password...</span>'';
            fade_on_empty = false;
            dots_spacing = 0.3;
            dots_center = true;
          }
        ];

        label = [
          {
            monitor = "";
            text = "$TIME";
            inherit font_family;
            font_size = 50;
            color = "rgb(${lib.removePrefix "#" colors.primary})";

            position = "0, 150";

            valign = "center";
            halign = "center";
          }
          {
            monitor = "";
            text = "cmd[update:3600000] date +'%a %b %d'";
            inherit font_family;
            font_size = 20;
            color = "rgb(${lib.removePrefix "#" colors.primary})";

            position = "0, 50";

            valign = "center";
            halign = "center";
          }
        ];
      };
    };
  };
}
