{
  inputs,
  lib,
  self,
  ...
}: {
  imports = [inputs.flake-parts.flakeModules.easyOverlay];
  perSystem = {
    pkgs,
    inputs',
    config,
    lib,
    ...
  }: let
    wl-ocr = pkgs.callPackage ./wl-ocr {};
    # My wallpaper collection - taken from misterio77 - https://github.com/Misterio77/nix-config
    wallpapers = import ./wallpapers {inherit pkgs;};
    allWallpapers = pkgs.linkFarmFromDrvs "wallpapers" (pkgs.lib.attrValues wallpapers);
    # And colorschemes based on it
    generateColorscheme = import ./colorschemes/generator.nix {inherit pkgs;};
    colorschemes = import ./colorschemes {inherit pkgs wallpapers generateColorscheme;};
    allColorschemes = let
      # This is here to help us keep IFD cached (hopefully)
      combined = pkgs.writeText "colorschemes.json" (builtins.toJSON (pkgs.lib.mapAttrs (_: drv: drv.imported) colorschemes));
    in
      pkgs.linkFarmFromDrvs "colorschemes" (pkgs.lib.attrValues colorschemes ++ [combined]);
  in {
    overlayAttrs = {
      inherit (config.packages) nordpvn wl-ocr;
      inherit (config.legacyPackages) wallpapers allWallpapers generateColorscheme colorschemes allColorschemes;
    };
    packages = {
      inherit wl-ocr;
    };
    legacyPackages = {
      inherit wallpapers allWallpapers generateColorscheme colorschemes allColorschemes;
    };
  };
}
