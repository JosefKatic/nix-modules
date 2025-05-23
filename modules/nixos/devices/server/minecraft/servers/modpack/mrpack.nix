{
  lib,
  stdenv,
  fetchurl,
  mrpack-install,
}:
stdenv.mkDerivation rec {
  pname = "minecraft-server-modpack";
  src = fetchurl {
    url = "https://cdn.modrinth.com/data/TK1lQFH6/versions/PXU2pZT5/Create%20%26%20Explore%20-%20pre2.1.0.mrpack";
    sha256 = "sha256-1XxZ15LWWILICGE+s9kDedkMijzilLo/LWtu3E+nAHo=";
  };

  buildInputs = [mrpack-install];

  dontUnpack = "true";

  installPhase = ''
    mkdir -p $out
    mrpack-install ${src} --server-dir "$out"

  '';

  meta = {
    description = "Minecraft server/modpack installed using mrpack-install";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [];
  };
}
