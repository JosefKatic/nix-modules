{
  lib,
  pkgs,
  bash,
  buildGoModule,
  fetchFromGitHub,
  appendOverlays,
  pkg-config,
  gcc,
  libxml2,
  wireguard-tools,
  buildFHSEnv,
}: let
  patchedPkgs = appendOverlays [
    (final: prev: {
      # Nordvpn uses a patched openvpn in order to perform xor obfuscation
      # See https://github.com/NordSecurity/nordvpn-linux/blob/e614303aaaf1a64fde5bb1b4de1a7863b22428c4/ci/openvpn/check_dependencies.sh
      openvpn = prev.openvpn.overrideAttrs (old: {
        patches =
          (old.patches or [])
          ++ [
            (prev.fetchpatch {
              url = "https://github.com/Tunnelblick/Tunnelblick/raw/v6.0/third_party/sources/openvpn/openvpn-${old.version}/patches/02-tunnelblick-openvpn_xorpatch-a.diff";
              hash = "sha256-b9NiWETc0g2a7FNwrLaNrWx7gfCql7VTbewFu3QluFk=";
            })
            (prev.fetchpatch {
              url = "https://github.com/Tunnelblick/Tunnelblick/raw/v6.0/third_party/sources/openvpn/openvpn-${old.version}/patches/03-tunnelblick-openvpn_xorpatch-b.diff";
              hash = "sha256-PfPAwZsyw6J3P6SlN6QTeg2pza9uSlDnziJtrX9fuI0=";
            })
            (prev.fetchpatch {
              url = "https://github.com/Tunnelblick/Tunnelblick/raw/v6.0/third_party/sources/openvpn/openvpn-${old.version}/patches/04-tunnelblick-openvpn_xorpatch-c.diff";
              hash = "sha256-5z9EoQaiV5f/IdnFXWtkaMNUi0yQLrqJ3yMvgXHRgkQ=";
            })
            (prev.fetchpatch {
              url = "https://github.com/Tunnelblick/Tunnelblick/raw/v6.0/third_party/sources/openvpn/openvpn-${old.version}/patches/05-tunnelblick-openvpn_xorpatch-d.diff";
              hash = "sha256-Ro35LAOXRFVYxdGGmn1Uwh3pB6fPUGTbDuOcb5T626s=";
            })
            (prev.fetchpatch {
              url = "https://github.com/Tunnelblick/Tunnelblick/raw/v6.0/third_party/sources/openvpn/openvpn-${old.version}/patches/06-tunnelblick-openvpn_xorpatch-e.diff";
              hash = "sha256-Xze9On9jgavtHikV3e9S92Cqp1WSFbDU0R8T8S6eyx4=";
            })
          ];
      });
    })
  ];
  nordvpn = buildGoModule rec {
    pname = "nordvpn";
    version = "3.20.0";

    #src = ./.;
    src = fetchFromGitHub {
      owner = "NordSecurity";
      repo = "nordvpn-linux";
      rev = "v6.0";
      sha256 = "sha256-FJPhcqHt0yhGaa95dv/eGwqwcTI91TQc2PmCZnS3iRs=";
    };

    nativeBuildInputs = [pkg-config gcc];

    buildInputs = [libxml2 gcc];

    vendorHash = "sha256-qWPHqhnG6k+XthJwr96iiZZDRfvmdUb87Ll76Nz+MFM=";

    ldflags = [
      "-X main.Version=${version}"
      "-X main.Environment=dev"
      "-X main.Salt=development"
      "-X main.Hash=${src.rev}"
    ];

    buildPhase = ''
      runHook preBuild
      echo "Building nordvpn CLI..."
      export LDFLAGS="${builtins.concatStringsSep " " ldflags}"
      go build -ldflags "$LDFLAGS" -o bin/nordvpn ./cmd/cli

      echo "Building nordvpn user..."
      go build -ldflags "$LDFLAGS" -o bin/norduserd ./cmd/norduser

      # Fix missing include in a library preventing compilation
      chmod +w vendor/github.com/jbowtie/gokogiri/xpath/
      sed -i '6i#include <stdlib.h>' vendor/github.com/jbowtie/gokogiri/xpath/expression.go

      echo "Building nordvpn daemon..."
      go build -ldflags "$LDFLAGS" -o bin/nordvpnd ./cmd/daemon
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib/nordvpn/
      mv bin/norduserd $out/lib/nordvpn/
      ln -s ${patchedPkgs.openvpn}/bin/openvpn $out/lib/nordvpn/openvpn
      ln -s ${wireguard-tools}/bin/wg $out/lib/nordvpn/wg

      # Nordvpn needs icons for the system tray and notifications
      mkdir -p $out/share/icons/hicolor/scalable/apps
      cp assets/icon.svg $out/share/icons/hicolor/scalable/apps/nordvpn.svg # Does not follow naming convention
      nordvpn_asset_prefix="nordvpn-" # hardcoded image prefix
      for file in assets/*; do
        cp "$file" "$out/share/icons/hicolor/scalable/apps/''\${nordvpn_asset_prefix}$(basename "$file")"
      done

      mkdir -p $out/bin
      cp bin/* $out/bin

      runHook postInstall
    '';

    meta = with lib; {
      description = "NordVPN CLI and daemon application for Linux";
      homepage = "https://github.com/nordsecurity/nordvpn-linux";
      mainProgram = "nordvpn";
      license = licenses.gpl3;
      platforms = platforms.linux;
    };
  };
in
  buildFHSEnv {
    name = "nordvpnd";
    targetPkgs = with pkgs;
      pkgs: [
        nordvpn
        sysctl
        iptables
        iproute2
        procps
        cacert
        libxml2
        libidn2
        zlib
        wireguard-tools
        patchedPkgs.openvpn
        e2fsprogs # for chattr
      ];

    extraInstallCommands = ''
      mkdir -p $out/bin/
      printf "#!${bash}/bin/bash\n${nordvpn}/bin/nordvpn \"\$@\"" > $out/bin/nordvpn
      chmod +x $out/bin/nordvpn
    '';

    runScript = ''
      ${nordvpn}/bin/nordvpnd
    '';
  }
