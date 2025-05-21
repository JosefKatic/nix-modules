{pkgs, ...}: let
  version = "1.20.1-47.3.25";
  installer = pkgs.fetchurl {
    pname = "forge-installer";
    inherit version;
    url = "https://maven.minecraftforge.net/net/minecraftforge/forge/${version}/forge-${version}-installer.jar";
    hash = "sha256-gM+Ma/JtBLae4gq49dVGwNmvxIxwK92JDuJrWFU71QE=";
  };
  java = "${pkgs.jdk17}/bin/java";
in
  pkgs.writeShellScriptBin "server" ''
    if ! [ -e "forge-${version}.jar" ]; then
      ${java} -jar ${installer} --installServer
    fi
    exec ${java} $@ -jar forge-${version}.jar nogui
  ''
