{
  config,
  pkgs,
  lib,
  ...
}: let
  hash = builtins.hashString "md5" (builtins.toJSON config.theme.colorscheme);
  rendersvg = pkgs.runCommand "rendersvg" {} ''
    mkdir -p $out/bin
    ln -s ${pkgs.resvg}/bin/resvg $out/bin/rendersvg
  '';
  materiaTheme = colors:
    pkgs.stdenv.mkDerivation {
      name = "generated-gtk-theme";
      src = pkgs.fetchFromGitHub {
        owner = "nana-4";
        repo = "materia-theme";
        rev = "76cac96ca7fe45dc9e5b9822b0fbb5f4cad47984";
        sha256 = "sha256-0eCAfm/MWXv6BbCl2vbVbvgv8DiUH09TAUhoKq7Ow0k=";
      };
      buildInputs = with pkgs; [
        sassc
        bc
        which
        rendersvg
        meson
        ninja
        nodePackages.sass
        gtk4.dev
        optipng
      ];
      phases = ["unpackPhase" "installPhase"];
      installPhase = ''
        HOME=/build
        chmod 777 -R .
        patchShebangs .
        mkdir -p $out/share/themes
        mkdir bin
        sed -e 's/handle-horz-.*//' -e 's/handle-vert-.*//' -i ./src/gtk-2.0/assets.txt

        cat > /build/gtk-colors << EOF
          BTN_BG=${colors.primary_container}
          BTN_FG=${colors.on_primary_container}
          BG=${colors.surface}
          FG=${colors.on_surface}
          HDR_BTN_BG=${colors.secondary_container}
          HDR_BTN_FG=${colors.on_secondary_container}
          ACCENT_BG=${colors.primary}
          ACCENT_FG=${colors.on_primary}
          HDR_BG=${colors.surface_bright}
          HDR_FG=${colors.on_surface}
          MATERIA_SURFACE=${colors.surface_bright}
          MATERIA_VIEW=${colors.surface_dim}
          MENU_BG=${colors.surface_container}
          MENU_FG=${colors.on_surface}
          SEL_BG=${colors.primary_fixed_dim}
          SEL_FG=${colors.on_primary}
          TXT_BG=${colors.primary_container}
          TXT_FG=${colors.on_primary_container}
          WM_BORDER_FOCUS=${colors.outline}
          WM_BORDER_UNFOCUS=${colors.outline_variant}
          UNITY_DEFAULT_LAUNCHER_STYLE=False
          NAME=generated-${hash}
          MATERIA_STYLE_COMPACT=True
        EOF

        echo "Changing colours:"
        ./change_color.sh -o generated-${hash} /build/gtk-colors -i False -t "$out/share/themes"
        chmod 555 -R .
      '';
    };
in {
  options.user.desktop.gtk = {
    enable = lib.mkEnableOption "Enable GTK settings";
  };
  config = lib.mkIf config.user.desktop.gtk.enable {
    home.pointerCursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 16;
      gtk.enable = true;
      x11.enable = true;
    };

    gtk = {
      enable = true;
      font = {
        name = "Fira Sans";
        package = pkgs.fira;
        size = 12;
      };
      theme = {
        name = "generated-${hash}";
        package = materiaTheme (
          lib.mapAttrs (_: v: lib.removePrefix "#" v) config.theme.colorscheme.colors
        );
      };
      iconTheme = {
        name = "Papirus";
        package = pkgs.papirus-icon-theme;
      };
    };

    services.xsettingsd = {
      enable = true;
      settings = {
        "Net/ThemeName" = "${config.gtk.theme.name}";
        "Net/IconThemeName" = "${config.gtk.iconTheme.name}";
      };
    };

    home.packages = with pkgs; [libdbusmenu-gtk3 sassc];

    xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];
  };
}
