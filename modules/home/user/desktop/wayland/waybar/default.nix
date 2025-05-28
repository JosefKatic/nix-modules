inputs: {
  config,
  lib,
  self,
  pkgs,
  ...
}: let
  cfg = config.user.desktop.wayland.waybar;
in {
  options.user.desktop.wayland.waybar.enable = lib.mkEnableOption "Enable Waybar";

  config = lib.mkIf cfg.enable {
    # Let it try to start a few more times
    systemd.user.services.waybar = {
      Unit.StartLimitBurst = 30;
    };
    programs.waybar = let
      logoFile = pkgs.fetchurl {
        url = "https://joka00.dev/assets/logo__dark.svg";
        sha256 = "1xd5hfxlh0m5687mfxndyv18a2k6aq7njna4n5smn7f7ynal1i28";
      };

      variant = config.programs.matugen.variant;
      colors = config.programs.matugen.theme.colors.colors.${variant};
      # Dependencies
      cat = "${pkgs.coreutils}/bin/cat";
      cut = "${pkgs.coreutils}/bin/cut";
      find = "${pkgs.findutils}/bin/find";
      grep = "${pkgs.gnugrep}/bin/grep";
      perl = "${pkgs.perl}/bin/perl";
      pgrep = "${pkgs.procps}/bin/pgrep";
      sed = "${pkgs.gnused}/bin/sed";
      tail = "${pkgs.coreutils}/bin/tail";
      wc = "${pkgs.coreutils}/bin/wc";
      xargs = "${pkgs.findutils}/bin/xargs";
      timeout = "${pkgs.coreutils}/bin/timeout";
      ping = "${pkgs.iputils}/bin/ping";

      jq = "${pkgs.jq}/bin/jq";
      xml = "${pkgs.xmlstarlet}/bin/xml";
      gamemoded = "${pkgs.gamemode}/bin/gamemoded";
      systemctl = "${pkgs.systemd}/bin/systemctl";
      journalctl = "${pkgs.systemd}/bin/journalctl";
      playerctl = "${pkgs.playerctl}/bin/playerctl";
      playerctld = "${pkgs.playerctl}/bin/playerctld";
      neomutt = "${pkgs.neomutt}/bin/neomutt";
      pavucontrol = "${pkgs.pavucontrol}/bin/pavucontrol";
      btop = "${pkgs.bottom}/bin/btop";
      wofi = "${pkgs.wofi}/bin/wofi";
      #  ikhal = "${pkgs.khal}/bin/ikhal";

      terminal = "${pkgs.kitty}/bin/kitty";
      terminal-spawn = cmd: "${terminal} $SHELL -i -c ${cmd}";

      #calendar = terminal-spawn ikhal;
      systemMonitor = terminal-spawn btop;
      mail = terminal-spawn neomutt;

      # Function to simplify making waybar outputs
      jsonOutput = name: {
        pre ? "",
        text ? "",
        tooltip ? "",
        alt ? "",
        class ? "",
        percentage ? "",
      }: "${pkgs.writeShellScriptBin "waybar-${name}" ''
        set -euo pipefail
        ${pre}
        ${jq} -cn \
          --arg text "${text}" \
          --arg tooltip "${tooltip}" \
          --arg alt "${alt}" \
          --arg class "${class}" \
          --arg percentage "${percentage}" \
          '{text:$text,tooltip:$tooltip,alt:$alt,class:$class,percentage:$percentage}'
      ''}/bin/waybar-${name}";

      hasSway = config.wayland.windowManager.sway.enable;
      sway = config.wayland.windowManager.sway.package;
      hasHyprland = config.wayland.windowManager.hyprland.enable;
      hyprland = config.wayland.windowManager.hyprland.package;

      clockTime = {
        format = "{:%R %p}";
      };
      clockDate = {
        format = "{:%b %e}";
      };
      groupClock = {
        orientation = "horizontal";
        drawer = {
          transition-duration = 500;
          children = "clock-member";
          transition-right-to-left = false;
        };
        modules = [
          "clock"
          "clock#Date"
        ];
      };

      hyprlandWorkspaces = {
        on-click = "activate";
        sort-by-number = true;
        persistent-workspaces = {
          "*" = 10;
        };
      };
      groupLogo = {
        orientation = "horizontal";
        drawer = {
          transition-duration = 500;
          children = "logo-member";
          transition-right-to-left = false;
        };
        modules = [
          "custom/logo"
          "custom/version"
        ];
      };
      customLogo = {
        format = "    ";
        tooltip = false;
      };
      customVersion = {
        interval = 10;
        return-type = "json";
        exec = jsonOutput "version-info" {
          # Build variables for each host
          pre = ''
            set -o pipefail
            lastModified=$(nix flake metadata self --json | ${jq} -r '.lastModified')
            date=$(date -d @$(nix flake metadata self --json | ${jq} -r '.lastModified') +%d/%m/%Y)
            version=$(nix flake metadata self --json | ${jq} -r '.revision' | ${cut} -c1-7)
          '';
          text = "$version ($date)";
          tooltip = "";
        };
        format = "{}";
        tooltip = false;
      };

      pulseaudio = {
        format = "{icon}  {volume}%";
        format-muted = "   0%";
        format-icons = {
          headphone = "󰋋";
          headset = "󰋎";
          portable = "";
          default = ["" "" ""];
        };
        on-click = pavucontrol;
      };
      battery = {
        bat = "BAT0";
        interval = 10;
        format-icons = ["󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
        format = "{icon} {capacity}%";
        format-charging = "󰂄 {capacity}%";
        onclick = "";
      };

      idleInhibitor = {
        format = "{icon}";
        format-icons = {
          activated = "󰒳";
          deactivated = "󰒲";
        };
      };
      customCurrentplayer = {
        interval = 2;
        return-type = "json";
        exec = jsonOutput "currentplayer" {
          pre = ''
            player="$(${playerctl} status -f "{{playerName}}" 2>/dev/null || echo "No player active" | ${cut} -d '.' -f1)"
            count="$(${playerctl} -l | ${wc} -l)"
            if ((count > 1)); then
              more=" +$((count - 1))"
            else
              more=""
            fi
          '';
          alt = "$player";
          tooltip = "$player ($count available)";
          text = "$more";
        };
        format = "{icon}{}";
        format-icons = {
          "No players found" = " ";
          "Celluloid" = "󰎁 ";
          "spotify" = " 󰓇";
          "ncspot" = " 󰓇";
          "qutebrowser" = "󰖟";
          "firefox" = " ";
          "discord" = " 󰙯 ";
          "sublimemusic" = " ";
          "kdeconnect" = "󰄡 ";
        };
        on-click = "${playerctld} shift";
        on-click-right = "${playerctld} unshift";
      };
      customPlayer = {
        exec-if = "${playerctl} status";
        exec = ''${playerctl} metadata --format '{"text": "{{artist}} - {{title}}", "alt": "{{status}}", "tooltip": "{{title}} ({{artist}} - {{album}})"}' '';
        return-type = "json";
        interval = 2;
        max-length = 30;
        format = "{icon} {}";
        format-icons = {
          "Playing" = "󰐊";
          "Paused" = "󰏤 ";
          "Stopped" = "󰓛";
        };
        on-click = "${playerctl} play-pause";
      };

      network = {
        interval = 3;
        format-wifi = "    {essid}";
        format-ethernet = "󰈁 Connected";
        format-disconnected = "";
        tooltip-format = ''
          {ifname}
          {ipaddr}/{cidr}
          Up: {bandwidthUpBits}
          Down: {bandwidthDownBits}'';
        on-click = "";
      };
      customTailscalePing = {
        interval = 2;
        return-type = "json";
        exec = let
          inherit (lib) concatStringsSep attrNames;
          hosts = attrNames self.nixosConfigurations;
          homeMachine = "regulus";
          remoteMachine = "strix";
        in
          jsonOutput "tailscale-ping" {
            # Build variables for each host
            pre = ''
              set -o pipefail
              ${concatStringsSep "\n" (map (host: ''
                  ping_${host}="$(${timeout} 2 ${ping} -c 1 -q ${host} 2>/dev/null | ${tail} -1 | ${cut} -d '/' -f5 | ${cut} -d '.' -f1)ms" || ping_${host}="Disconnected"
                '')
                hosts)}
            '';
            # Access a remote machine's and a home machine's ping
            text = "   $ping_${remoteMachine} /    $ping_${homeMachine}";
            # Show pings from all machines
            tooltip = concatStringsSep "\n" (map (host: "${host}: $ping_${host}") hosts);
          };
        format = "{}";
        on-click = "";
      };
      groupNetwork = {
        orientation = "horizontal";
        drawer = {
          transition-duration = 500;
          children-class = "network-member";
          transition-right-to-left = false;
        };
        modules = [
          "network"
          "custom/tailscale-ping"
        ];
      };
      tray = {
        icon-size = 21;
        spacing = 10;
      };
    in {
      enable = true;
      package = pkgs.waybar.overrideAttrs (oa: {
        mesonFlags = (oa.mesonFlags or []) ++ ["-Dexperimental=true"];
      });
      systemd.enable = true;
      settings = {
        bottom = {
          layer = "top";
          height = 32;
          margin = "6";
          position = "bottom";
          modules-left = [
            "group/clock"
          ];
          modules-center = [
            "hyprland/workspaces"
          ];
          modules-right = [
            "tray"
            "group/logo"
          ];
          clock = clockTime;
          "clock#Date" = clockDate;
          "group/clock" = groupClock;
          "hyprland/workspaces" = hyprlandWorkspaces;
          "custom/logo" = customLogo;
          "custom/version" = customVersion;
          "group/logo" = groupLogo;
          "tray" = tray;
        };
        primary = {
          layer = "top";
          height = 40;
          margin = "0";
          position = "top";
          output = builtins.map (m: m.name) (builtins.filter (m: m.primary) config.user.desktop.monitors);
          modules-left = [
            "group/network"
            "custom/currentplayer"
            "custom/player"
          ];
          modules-center = [
          ];
          modules-right = [
            "idle_inhibitor"
            "pulseaudio"
            "battery"
          ];

          network = network;
          "custom/tailscale-ping" = customTailscalePing;
          "group/network" = groupNetwork;
          pulseaudio = pulseaudio;
          "custom/currentplayer" = customCurrentplayer;
          "custom/player" = customPlayer;
          idle_inhibitor = idleInhibitor;
          battery = battery;
        };
      };
      # Cheatsheet:
      # x -> all sides
      # x y -> vertical, horizontal
      # x y z -> top, horizontal, bottom
      # w x y z -> top, right, bottom, left
      style = let
        inherit (inputs.nix-colors.lib.conversions) hexToRGBString;
        inherit (config.theme.colorscheme) colors;
        toRGBA = color: opacity: "rgba(${hexToRGBString "," (lib.removePrefix "#" color)},${opacity})";
      in
        /*
        css
        */
        ''
          * {
            font-family: 'Fira Sans', 'FiraCode Nerd Font';
            font-size: 12pt;
            padding: 0;
            margin: 0 0.4em;
          }
          #custom-logo {
            background-image: url('${logoFile}');
            background-position: center;
            background-repeat: no-repeat;
            background-size: contain;
          }
          window#waybar {
            padding: 0;
            border-radius: 0.5em;
            background-color: ${toRGBA colors.surface "0.3"};
            color: ${colors.on_surface};
          }
          .modules-left {
            margin-left: -0.65em;
            padding-left: 1em;
          }
          .modules-right {
            margin-right: -0.65em;
            padding-right: 1em;
          }

          #workspaces button {
            color: ${colors.on_surface};
            padding-left: 0.4em;
            padding-right: 0.4em;
            margin-top: 0.15em;
            margin-bottom: 0.15em;
          }
          #workspaces button.hidden {
            background-color: ${colors.surface};
            color: ${colors.on_surface_variant};
          }
          #workspaces button.focused,
          #workspaces button.active {
            background-color: ${colors.primary};
            color: ${colors.on_primary};
          }

          #clock {
          }
          #clock.Date {
          }

          #custom-currentplayer {
            padding-right: 0;
          }
          #tray {
            color: ${colors.on_surface};
          }
        '';
    };
  };
}
