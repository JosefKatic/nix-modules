{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.user.desktop.wayland.hyprland;
in {
  options.user.desktop.wayland.hyprland.settings = {
    mod = lib.mkOption {
      type = lib.types.str;
      default = "SUPER";
      description = "The modifier key used for keybindings";
    };
  };

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = let
      grimblast = "${pkgs.grimblast}/bin/grimblast";
      playerctl = "${pkgs.playerctl}/bin/playerctl";
      brillo = "${pkgs.brillo}/bin/brillo";
      wpctl = "${pkgs.wireplumber}/bin/wpctl";
      screenshotarea = "hyprctl keyword animation 'fadeOut,0,0,default'; ${grimblast} --notify copysave area; hyprctl keyword animation 'fadeOut,1,4,default'";
      workspaces = lib.concatLists (lib.genList (
          x: let
            ws = let
              c = (x + 1) / 10;
            in
              toString (x + 1 - (c * 10));
          in [
            "$mod, ${ws}, split:workspace, ${toString (x + 1)}"
            "$mod SHIFT, ${ws}, split:movetoworkspace, ${toString (x + 1)}"
          ]
        )
        10);
    in {
      cursor = {
        no_hardware_cursors = true;
      };
      # mouse movements
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
        "$mod ALT, mouse:272, resizewindow"
      ];

      # binds
      bind = let
        monocle = "dwindle:no_gaps_when_only";
      in
        [
          # compositor commands
          "$mod SHIFT, E, exit"
          "$mod SHIFT, X, killactive,"
          "$mod, F, fullscreen,"
          "$mod, G, togglegroup,"
          "$mod SHIFT, N, changegroupactive, f"
          "$mod SHIFT, P, changegroupactive, b"
          "$mod, R, togglesplit,"
          "$mod, T, togglefloating,"
          "$mod, P, pseudo,"
          "$mod ALT, ,resizeactive,"

          # toggle "monocle" (no_gaps_when_only)
          "$mod, M, exec, hyprctl keyword ${monocle} $(($(hyprctl getoption ${monocle} -j | jaq -r '.int') ^ 1))"

          # utility
          # terminal
          "$mod, Q, exec,kitty"
          "$mod, B, exec,${config.user.desktop.programs.browsers.default}"
          # logout menu
          "$mod, Escape, exec, ${pkgs.wlogout} -p layer-shell"
          # lock screen
          "$mod, backspace, exec, loginctl lock-session"
          # select area to perform OCR on
          "$mod, O, exec, run-as-service wl-ocr"

          # move focus
          "$mod, left, movefocus, l"
          "$mod, right, movefocus, r"
          "$mod, up, movefocus, u"
          "$mod, down, movefocus, d"

          # screenshot
          # stop animations while screenshotting; makes black border go away
          ", Print, exec, ${screenshotarea}"
          "$mod SHIFT, R, exec, ${screenshotarea}"

          "CTRL, Print, exec, ${grimblast} --notify --cursor copysave output"
          "$mod SHIFT CTRL, R, exec, ${grimblast} --notify --cursor copysave output"

          "ALT, Print, exec, ${grimblast} --notify --cursor copysave screen"
          "$mod SHIFT ALT, R, exec, ${grimblast} --notify --cursor copysave screen"

          # cycle workspaces
          "$mod, bracketleft, workspace, m-1"
          "$mod, bracketright, workspace, m+1"

          # cycle monitors
          "$mod SHIFT, bracketleft, focusmonitor, l"
          "$mod SHIFT, bracketright, focusmonitor, r"
        ]
        ++ workspaces;

      bindr = [
        # launcher
        "$mod, A, exec, pkill .anyrun-wrapped || run-as-service anyrun"
      ];

      bindl = [
        # media controls
        ", XF86AudioPlay, exec, ${playerctl} play-pause"
        ", XF86AudioPrev, exec,  ${playerctl} previous"
        ", XF86AudioNext, exec,  ${playerctl} next"

        # volume
        ", XF86AudioMute, exec, ${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute, exec, ${wpctl} set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
      ];

      bindle = [
        # volume
        ", XF86AudioRaiseVolume, exec, ${wpctl} set-volume -l '1.0' @DEFAULT_AUDIO_SINK@ 6%+"
        ", XF86AudioLowerVolume, exec, ${wpctl} set-volume -l '1.0' @DEFAULT_AUDIO_SINK@ 6%-"

        # backlight
        ", XF86MonBrightnessUp, exec, ${brillo} -q -u 300000 -A 5"
        ", XF86MonBrightnessDown, exec, ${brillo} -q -u 300000 -U 5"
      ];
    };
  };
}
