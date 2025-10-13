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
          "${pkgs.anyrun}/lib/libapplications.so"
          "${pkgs.anyrun}/lib/libwebsearch.so"
          "${pkgs.anyrun}/lib/libnix_run.so"
        ];
        width.fraction = 0.3;
        y.absolute = 15;
        hidePluginInfo = true;
        closeOnClick = true;
      };

      extraCss = ''
        * {
          all: unset;
          font-size: 1rem;
        }

        window {
          background: transparent;
        }

        box.main {
          background: #131313;
          border: 2px solid #ffffff;
          border-radius: 4px;
          margin: 8px;
          padding: 16px 16px;
        }

        .matches {
          background-color: rgba(0, 0, 0, 0);
          border-radius: 10px;
        }

        .matches > row.match:first {
          margin-top: 0;
        }

        box.plugin:first-child {
          margin-top: 5px;
        }

        box.plugin.info {
          min-width: 200px;
        }

        list.plugin {
          background-color: rgba(0, 0, 0, 0);
        }

        label.match.description {
          font-size: 10px;
        }

        label.plugin.info {
          font-size: 14px;
        }

        row.match {
          border-radius: 8px;
          margin-top: 0.25rem;
        }

        box.match {
          background: transparent;
          border-radius: 8px;
          padding: 0.1rem 0.25rem;
        }

        .match:selected,
        .match:hover {
          background: #ffffff;
          color: #1b1b1b;
        }

        list > .plugin {
          border-radius: 8px;
          margin: 0 0.3rem;
        }
        list > .plugin:first-child {
          margin-top: 0.3rem;
        }
        list > .plugin:last-child {
          margin-bottom: 0.3rem;
        }
        list > .plugin {
          padding: 0.2rem;
        }
      '';
      extraConfigFiles = {
        "applications.ron".text = ''
          Config(
            desktop_actions: true,
            max_entries: 5,
            terminal: Some(Terminal(
              command: "kitty",
              args: "{}",
            )),
          )
        '';
        "websearch.ron".text = ''
          Config(
            prefix: "?",
            engines: [Google]
          )
        '';
        "nix-run.ron".text = ''
          Config(
            prefix: ":nr ",
            allow_unfree: true,
            channel: "nixpkgs-unstable",
            max_entries: 3,
          )
        '';
      };
    };
  };
}
