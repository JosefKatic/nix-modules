{pkgs, ...}: let
  version = "1.20.1-47.4.0";
  installer = pkgs.fetchurl {
    pname = "forge-installer";
    inherit version;
    url = "https://maven.minecraftforge.net/net/minecraftforge/forge/${version}/forge-${version}-installer.jar";
    hash = "sha256-8/V0ZeLL3DKBk/d7p/DJTLZEBfMe1VZ1PZJ16L3Abiw=";
  };
  java = "${pkgs.jre8}/bin/java";
in
  pkgs.writeShellScriptBin "server" ''
    if ! [ -e "forge-${version}.jar" ]; then
      ${java} -jar ${installer} --installServer
    fi
    exec ${java} $@ -jar forge-${version}.jar nogui
  ''
