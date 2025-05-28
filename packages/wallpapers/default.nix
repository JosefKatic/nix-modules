{pkgs}:
pkgs.lib.listToAttrs (
  map (wallpaper: {
    inherit (wallpaper) name;
    value = pkgs.fetchurl {
      inherit (wallpaper) sha256;
      name = "${wallpaper.name}.${wallpaper.ext}";
      url = "https://i.imgur.com/${wallpaper.id}.${wallpaper.ext}";
    };
  }) (pkgs.lib.importJSON ./list.json)
)
// {
  binary-black = fetchurl {
    name = "binary-black.png";
    url = "https://raw.githubusercontent.com/NixOS/nixos-artwork/8957e93c95867faafec7f9988cedddd6837859fa/wallpapers/nix-wallpaper-binary-black.png";
    hash = "sha256-mhSh0wz2ntH/kri3PF5ZrFykjjdQLhmlIlDDGFQIYWw=";
  };
}
