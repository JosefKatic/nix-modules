{
  config,
  lib,
  pkgs,
  ...
}: {
  options.device.boot.quietboot.enable = lib.mkEnableOption "Enable quiet boot";

  config = lib.mkIf config.device.boot.quietboot.enable {
    console = {
      useXkbConfig = true;
      earlySetup = false;
    };

    boot = {
      plymouth = let
        logoFile = pkgs.fetchurl {
          url = "https://joka00.dev/assets/logo_black.png";
          hash = "sha256-DRlA59xQy2kaanKtDGMdE98272vglKThfPNAPnE1o0M=";
        };
      in {
        enable = true;
        theme = "blockchain";
        themePackages = with pkgs; [
          # By default we would install all themes
          (adi1090x-plymouth-themes.override {
            selected_themes = ["blockchain"];
          })
        ];
        logo = logoFile;
      };
      loader.timeout = 0;
      kernelParams = [
        "quiet"
        "loglevel=3"
        "systemd.show_status=auto"
        "udev.log_level=3"
        "rd.udev.log_level=3"
        "vt.global_cursor_default=0"
      ];
      consoleLogLevel = 0;
      initrd.verbose = false;
    };
  };
}
