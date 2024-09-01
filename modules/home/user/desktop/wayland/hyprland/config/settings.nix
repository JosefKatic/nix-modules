{
  config,
  lib,
  ...
}: let
  cfg = config.user.desktop.wayland.hyprland;
in {
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = let
      active = "0xaa${lib.removePrefix "#" config.theme.colorscheme.colors.primary}";
      inactive = "0xaa${lib.removePrefix "#" config.theme.colorscheme.colors.surface_bright}";
      pointer = config.home.pointerCursor;
    in {
      "$mod" = cfg.settings.mod;
      env = [
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
      ];

      exec-once = [
        # set cursor for HL itself
        "hyprctl setcursor ${pointer.name} ${toString pointer.size}"
        "systemctl --user start clight"
      ];

      general = {
        gaps_in = 5;
        gaps_out = 5;
        border_size = 1;
        "col.active_border" = active;
        "col.inactive_border" = inactive;
        allow_tearing = true;
      };

      decoration = {
        rounding = 5;
        blur = {
          enabled = true;
          size = 5;
          passes = 3;
          new_optimizations = true;
          ignore_opacity = true;
        };

        drop_shadow = true;
        shadow_ignore_window = true;
        shadow_offset = "3 3";
        shadow_range = 12;
        shadow_render_power = 3;
        "col.shadow" = "rgba(00000055)";
      };

      animations = {
        enabled = true;
        bezier = [
          "easein,0.11, 0, 0.5, 0"
          "easeout,0.5, 1, 0.89, 1"
          "easeinout,0.45, 0, 0.55, 1"
        ];

        animation = [
          "windowsIn,1,3,easeout,slide"
          "windowsOut,1,3,easein,slide"
          "windowsMove,1,3,easeout"
          "workspaces,1,2,easeout,slide"
          "fadeIn,1,3,easeout"
          "fadeOut,1,3,easein"
          "fadeSwitch,1,3,easeout"
          "fadeShadow,1,3,easeout"
          "fadeDim,1,3,easeout"
          "border,1,3,easeout"
        ];
        # animation = [
        # "border, 1, 2, default"
        # "fade, 1, 4, default"
        # "windows, 1, 3, default, popin 80%"
        # "workspaces, 1, 2, default, slide"
        # ];
      };

      group = {
        groupbar = {
          font_size = 16;
          gradients = false;
        };
        "col.border_active" = active;
        "col.border_inactive" = inactive;
      };

      input = {
        kb_layout = "cz";
        kb_variant = "coder";
        numlock_by_default = true;
        # focus change on cursor move
        follow_mouse = 1;
        accel_profile = "flat";
        touchpad.scroll_factor = 0.1;
      };

      dwindle = {
        # keep floating dimentions while tiling
        pseudotile = true;
        preserve_split = true;
      };

      misc = {
        # disable auto polling for config file changes
        disable_autoreload = true;

        force_default_wallpaper = 0;

        # disable dragging animation
        animate_mouse_windowdragging = false;

        # enable variable refresh rate (effective depending on hardware)
        vrr = 1;

        vfr = true;
        close_special_on_empty = true;
        focus_on_activate = true;
        # Unfullscreen when opening something
        new_window_takes_over_fullscreen = 2;

        disable_hyprland_logo = true;
        disable_splash_rendering = true;
      };

      # touchpad gestures
      gestures = {
        workspace_swipe = true;
        workspace_swipe_fingers = 4;
        workspace_swipe_forever = true;
      };
      xwayland.force_zero_scaling = true;

      debug.disable_logs = false;

      monitor = let
        inherit (config.wayland.windowManager.hyprland.settings.general) gaps_in gaps_out;
        gap = gaps_out - gaps_in;
        waybarSpaces =
          builtins.concatMap (
            bar: let
              inherit (bar) position height width;
              waybarSpace = {
                top =
                  if (position == "top")
                  then height + gap
                  else 0;
                bottom =
                  if (position == "bottom")
                  then height + gap
                  else 0;
                left =
                  if (position == "left")
                  then width + gap
                  else 0;
                right =
                  if (position == "right")
                  then width + gap
                  else 0;
              };
              addreservedString = ",addreserved,${toString waybarSpace.top},${toString waybarSpace.bottom},${toString waybarSpace.left},${toString waybarSpace.right}";
              outputs = bar.outputs or [];
            in
              if outputs == []
              then [addreservedString]
              else map (output: "${output}${addreservedString}") outputs
          )
          (attrValues config.programs.waybar.settings);
      in
        waybarSpaces
        ++ (map (
          m: "${m.name},${
            if m.enabled
            then "${toString m.width}x${toString m.height}@${toString m.refreshRate},${m.position},1"
            else "disable"
          }"
        ) (config.user.desktop.monitors));
    };
  };
}
