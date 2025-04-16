{
  lib,
  options,
  config,
  pkgs,
  ...
}: let
  cfg = config.device.core;
in {
  options.device.core.locale = {
    defaultLocale = lib.mkOption {
      type = options.i18n.defaultLocale.type;
      default = "en_US.UTF-8/UTF-8";
    };
    supportedLocales = lib.mkOption {
      type = options.i18n.supportedLocales.type;
      default = ["en_US.UTF-8/UTF-8" "cs_CZ.UTF-8/UTF-8"];
    };
    timeZone = lib.mkOption {
      type = options.time.timeZone.type;
      default = "Europe/Prague";
    };
  };
  config = {
    i18n = {
      defaultLocale = cfg.locale.defaultLocale;
      supportedLocales = cfg.locale.supportedLocales;
    };
    time.timeZone = cfg.locale.timeZone;

    fonts = {
      packages = with pkgs; [
        # icon fonts
        material-symbols
        material-design-icons

        # Sans(Serif) fonts
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-emoji
        fira-code
        inter
        roboto
        dosis
        rubik
        (google-fonts.override {fonts = ["Inter"];})

        # monospace fonts
        jetbrains-mono
        # nerdfonts
        nerd-fonts.iosevka
        nerd-fonts.fira-code
      ];

      # causes more issues than it solves
      enableDefaultPackages = false;

      # user defined fonts
      # the reason there's Noto Color Emoji everywhere is to override DejaVu's
      # B&W emojis that would sometimes show instead of some Color emojis
      fontconfig.defaultFonts = {
        serif = ["Noto Serif" "Noto Color Emoji"];
        sansSerif = ["Inter" "Noto Color Emoji"];
        monospace = ["JetBrains Mono" "Noto Color Emoji"];
        emoji = ["Noto Color Emoji"];
      };
    };
  };
}
