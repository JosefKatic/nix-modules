{
  config,
  lib,
  ...
}: let
  cfg = config.user.desktop.wayland.hyprland;
in {
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      # layer rules
      layerrule = let
        toRegex = list: let
          elements = lib.concatStringsSep "|" list;
        in "^(${elements})$";

        ignorealpha = [
          # ags
          "blur,waybar"
          "ignorezero,waybar"
          "blur,notifications"
          "ignorezero,notifications"
          "osd"
          "system-menu"
          "anyrun"
        ];

        layers = ignorealpha ++ ["bar" "gtk-layer-shell"];
      in [
        "blur, ${toRegex layers}"
        "xray 1, ${toRegex ["bar" "gtk-layer-shell"]}"
        "ignorealpha 0.2, ${toRegex ["bar" "gtk-layer-shell"]}"
        "ignorealpha 0.5, ${toRegex (ignorealpha ++ ["music"])}"
      ];

      # window rules
      windowrulev2 = [
        # telegram media viewer
        "float, title:^(Media viewer)$"

        # allow tearing in games
        "immediate, class:^(osu\!|cs2)$"

        # make Firefox PiP window floating and sticky
        "float, title:^(Picture-in-Picture)$"
        "pin, title:^(Picture-in-Picture)$"

        # throw sharing indicators away
        "workspace special silent, title:^(Firefox — Sharing Indicator)$"
        "workspace special silent, title:^(.*is sharing (your screen|a window)\.)$"

        # idle inhibit while watching videos
        "idleinhibit focus, class:^(mpv|.+exe|celluloid)$"
        "idleinhibit focus, class:^(firefox|zen|brave|chromium)$, title:^(.*YouTube.*)$"
        "idleinhibit fullscreen, class:^(firefox|zen|brave|chromium)$"

        "dimaround, class:^(gcr-prompter)$"

        # fix xwayland apps
        "rounding 0, xwayland:1"
      ];
    };
  };
}
