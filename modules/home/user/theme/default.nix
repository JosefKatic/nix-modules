inputs: {
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.theme.colorscheme;
  inherit (lib) types mkOption;

  hexColor = types.strMatching "#([0-9a-fA-F]{3}){1,2}";

  removeFilterPrefixAttrs = prefix: attrs:
    lib.mapAttrs' (n: v: {
      name = lib.removePrefix prefix n;
      value = v;
    }) (lib.filterAttrs (n: _: lib.hasPrefix prefix n) attrs);
in {
  options.theme = {
    colorscheme = {
      source = mkOption {
        type = types.either types.path hexColor;
        default =
          if config.theme.wallpaper != null
          then config.theme.wallpaper
          else "#FFFFFF";
      };
      mode = mkOption {
        type = types.enum ["dark" "light"];
        default = "dark";
      };
      type = mkOption {
        type = types.enum (inputs.self.legacyPackages.${pkgs.system}.generateColorscheme null null).schemeTypes;
        default = "tonal-spot";
      };
      generatedDrv = mkOption {
        type = types.package;
        default = inputs.self.legacyPackages.${pkgs.system}.generateColorscheme (cfg.source.name or "default") cfg.source;
      };
      rawColorscheme = mkOption {
        type = types.attrs;
        default = cfg.generatedDrv.imported.${cfg.type};
      };

      colors = mkOption {
        readOnly = true;
        type = types.attrsOf hexColor;
        default = cfg.rawColorscheme.colors.${cfg.mode};
      };
    };
    wallpaper = lib.mkOption {
      description = ''
        Location of the wallpaper to use throughout the system.
      '';
      default = inputs.self.legacyPackages.${pkgs.system}.wallpapers.astronaut-minimalism;
      type = types.path;
      example = lib.literalExample "./wallpaper.png";
    };
  };
}
