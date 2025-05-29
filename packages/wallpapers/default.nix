{pkgs}:
pkgs.lib.listToAttrs (
  map (wallpaper: {
    inherit (wallpaper) name;
    value = pkgs.fetchurl {
      inherit (wallpaper) hash;
      name = "${wallpaper.name}.${wallpaper.ext}";
      url = wallpaper.url;
    };
  }) (pkgs.lib.importJSON ./list.json)
)
