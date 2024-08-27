{
  config,
  lib,
  pkgs,
  ...
}: let
  suspendScript = pkgs.writeShellScript "suspend-script" ''
    ${pkgs.pipewire}/bin/pw-cli i all 2>&1 | ${pkgs.ripgrep}/bin/rg running -q
    # only suspend if audio isn't running
    if [ $? == 1 ]; then
      ${pkgs.systemd}/bin/systemctl suspend
    fi
  '';
  cfg = config.user.desktop.wayland.hyprland.services.hypridle;
in {
  options.user.desktop.wayland.hyprland.services.hypridle.enable = lib.mkEnableOption "Enable Hypridle";

  config = lib.mkIf cfg.enable {
    systemd.user.services.hypridle.Install.WantedBy = lib.mkForce ["hyprland-session.target"];

    services.hypridle = let
      hyprlock = "${config.programs.hyprlock.package}/bin/hyprlock";
      pgrep = "${pkgs.procps}/bin/pgrep";
      pactl = "${pkgs.pulseaudio}/bin/pactl";
      hyprctl = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl";
      swaymsg = "${config.wayland.windowManager.sway.package}/bin/swaymsg";
      suspendScript = pkgs.writeShellScript "suspend-script" ''
        ${pkgs.pipewire}/bin/pw-cli i all 2>&1 | ${pkgs.ripgrep}/bin/rg running -q
        # only suspend if audio isn't running
        if [ $? == 1 ]; then
          ${pkgs.systemd}/bin/systemctl suspend
        fi
      '';
      isLocked = "${pgrep} -x ${hyprlock}";
      lockTime = 600;
      afterLockTimeout = {
        timeout,
        on-timeout,
        on-resume ? null,
      }: [
        {
          timeout = lockTime + timeout;
          inherit on-timeout on-resume;
        }
        {
          on-timeout = "${isLocked} && ${on-timeout}";
          inherit on-resume timeout;
        }
      ];
    in {
      enable = true;
      settings = {
        general = {
          lock_cmd = lib.getExe config.programs.hyprlock.package;
          before_sleep_cmd = "${pkgs.systemd}/bin/loginctl lock-session";
        };
        listener =
          [
            {
              timeout = lockTime;
              on-timeout = "${pkgs.systemd}/bin/loginctl lock-session";
              on-resume = "";
            }
          ]
          ++
          # Mute mic
          (afterLockTimeout {
            timeout = 10;
            on-timeout = "${pactl} set-source-mute @DEFAULT_SOURCE@ yes";
            on-resume = "${pactl} set-source-mute @DEFAULT_SOURCE@ no";
          })
          ++
          # Suspend
          (afterLockTimeout {
            timeout = 600;
            on-timeout = suspendScript.outPath;
            on-resume = "";
          })
          ++
          # Turn off displays (hyprland)
          (lib.optionals config.wayland.windowManager.hyprland.enable (afterLockTimeout {
            timeout = 300;
            on-timeout = "${hyprctl} dispatch dpms off";
            on-resume = "${hyprctl} dispatch dpms on";
          }));
      };
    };
  };
}
