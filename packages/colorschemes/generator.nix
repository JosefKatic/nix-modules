{pkgs, ...}: let
  inherit (pkgs) lib;
  generateColorscheme = name: source: let
    schemeTypes = ["content" "expressive" "fidelity" "fruit-salad" "monochrome" "neutral" "rainbow" "tonal-spot"];
    isHexColor = c: lib.isString c && (builtins.match "#([0-9a-fA-F]{3}){1,2}" c) != null;

    config = (pkgs.formats.toml {}).generate "config.toml" {
      templates = {};
      config = {
        custom_colors = {
          red = "#ffb2b9";
          orange = "#ffb3ae";
          yellow = "#dcff8e";
          green = "#45f89c";
          cyan = "#a1f0ff";
          blue = "#b0c6ff";
          magenta = "#eab2ff";
        };
      };
    };
  in
    pkgs.runCommand "colorscheme-${name}" {
      # __contentAddressed = true;
      passthru = let
        drv = generateColorscheme name source;
      in {
        inherit schemeTypes;
        # Incurs IFD
        imported = lib.genAttrs schemeTypes (scheme: lib.importJSON "${drv}/${scheme}.json");
      };
    } ''
      mkdir "$out" -p
      for type in ${lib.concatStringsSep " " schemeTypes}; do
        ${pkgs.matugen}/bin/matugen ${
        if (isHexColor source)
        then "color hex"
        else "image"
      } --config ${config} -j hex -t "scheme-$type" "${source}" > "$out/$type.json"
      done
    '';
in
  generateColorscheme
