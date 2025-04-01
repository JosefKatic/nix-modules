inputs: {
  config,
  lib,
  options,
  pkgs,
  ...
}:
with lib; let
  cfg = config.user.desktop.programs.browsers;
  stigConfig = import ./stig.nix;
  jsonFormat = pkgs.formats.json {};
in {
  options.user.desktop.programs.browsers.firefox = {
    enable = lib.mkEnableOption "Enable Firefox Browser";
    extraPolicies = lib.mkOption {
      type = options.programs.firefox.policies.type;
      default = {};
    };
    extensions = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = with pkgs.nur.repos.rycee.firefox-addons; [
        ublock-origin
        privacy-badger
        clearurls
        decentraleyes
        languagetool
      ];
    };
    defaultTheme = lib.mkOption {
      type = lib.types.str;
      default = "minimal";
      example = "cascade";
    };
    settings = lib.mkOption {
      type = types.attrsOf (jsonFormat.type
        // {
          description = "Firefox preference (int, bool, string, and also attrs, list, float as a JSON string)";
        });
      default = {
        "general.smoothScroll" = true;
        "dom.security.https_only_mode" = true;
        "identity.fxaccounts.enabled" = false;
        "privacy.trackingprotection.enabled" = true;
      };
    };
    search = {
      force = mkOption {
        type = with types; bool;
        default = true;
      };

      default = mkOption {
        type = with types; str;
        default = "google";
      };

      privateDefault = mkOption {
        type = with types; str;
        default = "ddg";
      };

      engines = mkOption {
        type = with types; attrsOf (attrsOf jsonFormat.type);
        default = {
          "Nix Packages" = {
            urls = [
              {
                template = "https://search.nixos.org/packages";
                params = [
                  {
                    name = "type";
                    value = "packages";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = ["@np"];
          };
          "NixOS Wiki" = {
            urls = [
              {
                template = "https://nixos.wiki/index.php?search={searchTerms}";
              }
            ];
            icon = "https://nixos.wiki/favicon.png";
            updateInterval = 24 * 60 * 60 * 1000;
            definedAliases = ["@nw"];
          };
          "wikipedia".metaData.alias = "@wiki";
          "amazondotcom-us".metaData.hidden = true;
          "bing".metaData.hidden = true;
          "ebay".metaData.hidden = true;
        };
      };
    };
    profiles = lib.mkOption {
      type = options.programs.firefox.profiles.type;
      default = {};
    };
  };

  config = lib.mkIf cfg.firefox.enable {
    programs.firefox = {
      enable = true;
      policies =
        {
          CaptivePortal = true;
          DisableFirefoxStudies = true;
          DisablePocket = true;
          DisableTelemetry = true;
          DisableFirefoxAccounts = false;
          NoDefaultBookmarks = true;
          OfferToSaveLogins = false;
          OfferToSaveLoginsDefault = false;
          PasswordManagerEnabled = false;
          FirefoxHome = {
            Search = true;
            Pocket = false;
            Snippets = false;
            TopSites = false;
            Highlights = false;
          };
          UserMessaging = {
            ExtensionRecommendations = false;
            SkipOnboarding = true;
          };
        }
        // cfg.firefox.extraPolicies;
      profiles =
        {
          "company" = {
            extensions.packages = cfg.firefox.extensions;
            search = cfg.firefox.search;
            settings = cfg.firefox.settings // stigConfig;
            userContent = import "${inputs.self}/modules/home/user/desktop/programs/browsers/firefox/${cfg.firefox.defaultTheme}/user-content.nix";
            userChrome = import "${inputs.self}/modules/home/user/desktop/programs/browsers/firefox/${cfg.firefox.defaultTheme}/user-chrome.nix";
          };
        }
        // cfg.firefox.profiles;
    };
  };
}
