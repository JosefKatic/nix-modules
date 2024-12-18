{
  pkgs,
  lib,
  config,
  ...
}: let
  enabledMonitors = lib.filter (m: m.enabled) config.user.desktop.monitors;
  # A nice VNC script for remotes running hyprland
  vncsh = pkgs.writeShellScriptBin "vnc.sh" ''
    ssh $1 bash <<'EOF'
        pgrep "wayvnc" && exit
        export HYPRLAND_INSTANCE_SIGNATURE="$(${pkgs.coreutils}/bin/ls "$XDG_RUNTIME_DIR/hypr/" -lt | head -2 | tail -1 | rev | cut -d ' ' -f1 | rev)"
        export WAYLAND_DISPLAY="wayland-1"
        ip="$(ip addr show dev tailscale0 | grep 'inet ' | xargs | cut -d ' ' -f2 | cut -d '/' -f1)"
        ${lib.concatLines (
      lib.forEach enabledMonitors (m: ''
        hyprctl output create headless
        monitor="$(hyprctl monitors -j | ${pkgs.jq}/bin/jq -r 'map(.name)[-1]')"
        hyprctl keyword monitor "$monitor,${toString m.width}x${toString m.height}@60,${toString m.position},1"
        ${pkgs.screen}/bin/screen -d -m wayvnc -k br -S /tmp/vnc-${m.workspace} -f 60 -o "$monitor" "$ip" 590${m.workspace}
        sudo iptables -I INPUT -j ACCEPT -p tcp --dport 590${m.workspace}
      '')
    )}
    EOF

    ${lib.concatLines (
      lib.forEach enabledMonitors (m: ''
        hyprctl dispatch moveworkspacetomonitor name:F${m.workspace} ${m.name}
        hyprctl dispatch focusmonitor ${m.name}
        hyprctl dispatch workspace name:F${m.workspace}
        sleep 0.5
        vncviewer $1::590${m.workspace} &
        sleep 1
        hyprctl dispatch fullscreen 0
      '')
    )}

    wait

    ssh $1 bash <<'EOF'
        pgrep "wayvnc" && exit
        export HYPRLAND_INSTANCE_SIGNATURE="$(${pkgs.coreutils}/bin/ls "$XDG_RUNTIME_DIR/hypr/" -lt | head -2 | tail -1 | rev | cut -d ' ' -f1 | rev)"
        export WAYLAND_DISPLAY="wayland-1"

        ${lib.concatLines (
      lib.forEach enabledMonitors (m: ''
        monitor="$(hyprctl monitors -j | ${pkgs.jq}/bin/jq -r 'map(.name)[-1]')"
        hyprctl output remove "$monitor"
      '')
    )}
    EOF

  '';
in {
  home.packages = with pkgs; [
    vncsh
    wayvnc
    tigervnc
  ];
}
