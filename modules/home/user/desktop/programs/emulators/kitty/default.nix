{
  config,
  lib,
  ...
}: let
  inherit (config.theme.colorscheme) colors;
  cfg = config.user.desktop.programs.emulators.kitty;
in {
  options.user.desktop.programs.emulators.kitty = {
    enable = lib.mkEnableOption "Enable Kitty";
  };
  config = lib.mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      font = {
        size = 12;
        name = "JetBrains Mono";
      };

      settings = {
        scrollback_lines = 10000;
        window_padding_width = 15;
        placement_strategy = "center";

        allow_remote_control = "yes";
        enable_audio_bell = "no";
        visual_bell_duration = "0.1";

        copy_on_select = "clipboard";

        foreground = "${colors.on_surface}";
        background = "${colors.surface}";
        selection_background = "${colors.on_surface}";
        selection_foreground = "${colors.surface}";
        url_color = "${colors.on_surface_variant}";
        cursor = "${colors.on_surface}";
        active_border_color = "${colors.outline}";
        inactive_border_color = "${colors.surface_bright}";
        active_tab_background = "${colors.surface}";
        active_tab_foreground = "${colors.on_surface}";
        inactive_tab_background = "${colors.surface_bright}";
        inactive_tab_foreground = "${colors.on_surface_variant}";
        tab_bar_background = "${colors.surface_bright}";
        color0 = "${colors.surface}";
        color1 = "${colors.red_value}";
        color2 = "${colors.green_value}";
        color3 = "${colors.yellow_value}";
        color4 = "${colors.blue_value}";
        color5 = "${colors.magenta_value}";
        color6 = "${colors.cyan_value}";
        color7 = "${colors.on_surface}";
        color8 = "${colors.outline}";
        color9 = "${colors.red_value}";
        color10 = "${colors.green_value}";
        color11 = "${colors.yellow_value}";
        color12 = "${colors.blue_value}";
        color13 = "${colors.magenta_value}";
        color14 = "${colors.cyan_value}";
        color15 = "${colors.surface_dim}";
        color16 = "${colors.orange_value}";
        color17 = "${colors.error}";
        color18 = "${colors.surface_bright}";
        color19 = "${colors.surface_container}";
        color20 = "${colors.on_surface_variant}";
        color21 = "${colors.inverse_surface}";
      };
    };
  };
}
