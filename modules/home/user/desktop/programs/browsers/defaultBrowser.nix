{
  config,
  lib,
  ...
}: let
  cfg = config.user.desktop.programs.browsers;
in {
  options.user.desktop.programs.browsers = {
    default = lib.mkOption {
      type = lib.types.enum ["firefox" "chromium" "brave" "zen"];
      default = "firefox";
      description = "Default browser";
    };
  };

  config = {
    home = {sessionVariables.BROWSER = "${cfg.default}";};

    xdg.mimeApps.defaultApplications = let
      defaultBrowser = "${cfg.default}.desktop";
    in {
      "text/html" = ["${defaultBrowser}"];
      "text/xml" = ["${defaultBrowser}"];
      "x-scheme-handler/http" = ["${defaultBrowser}"];
      "x-scheme-handler/https" = ["${defaultBrowser}"];
    };
  };
}
