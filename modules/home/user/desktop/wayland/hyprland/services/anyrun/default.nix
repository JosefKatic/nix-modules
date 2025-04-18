{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (config.theme.colorscheme) colors;
  cfg = config.user.desktop.wayland.hyprland.services.anyrun;
in {
  options.user.desktop.wayland.hyprland.services.anyrun = {
    enable = lib.mkEnableOption "Enable anyrun";
  };
  config = lib.mkIf cfg.enable {
    programs.anyrun = {
      enable = true;
      config = {
        plugins = [
          "applications"
          "websearch"
        ];

        width.fraction = 0.3;
        y.absolute = 15;
        hidePluginInfo = true;
        closeOnClick = true;
      };

      extraCss = ''
        * {
          all: unset;
          font-size: 1.3rem;
        }

        #window,
        #match,
        #entry,
        #plugin,
        #main {
          background: transparent;
        }

        #match.activatable {
          border-radius: 8px;
          padding: 0.3rem 0.9rem;
          margin-top: 0.25rem;
        }
        #match.activatable:first-child {
          margin-top: 0.7rem;
        }
        #match.activatable:last-child {
          margin-bottom: 0.6rem;
        }

        #match:selected,
        #match:hover
        {
          background: ${colors.primary};
          color: ${colors.on_primary};
        }

        #entry {
          background: ${colors.surface};
          border-radius: 8px;
          margin: 0.5rem;
          padding: 0.3rem 1rem;
        }

        list > #plugin {
          border-radius: 8px;
          margin: 0 0.3rem;
        }
        list > #plugin:first-child {
          margin-top: 0.3rem;
        }
        list > #plugin:last-child {
          margin-bottom: 0.3rem;
        }
        list > #plugin {
          padding: 0.6rem;
        }

        box#main {
          background: ${colors.surface};
          border: 2px solid ${colors.primary};
          border-radius: 4px;
          padding: 0.3rem;
        }
      '';
      extraConfigFiles = {
        "applications.ron".text = ''
          Config(
            desktop_actions: true,
            max_entries: 5,
            terminal: Some("kitty"),
          )
        '';
        "websearch.ron".text = ''
          Config(
            prefix: "?",
            engines: [Google]
          )
        '';
      };
    };
  };
}
