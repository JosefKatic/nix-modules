{
  stdenv,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  home-assistant,
  python312Packages,
}: let
  importlib-resources = python312Packages.callPackage ./importlib-resources.nix {};
  pydantic = python312Packages.pydantic;
  sigstore-rekor-types = python312Packages.callPackage ./sigstore-rekor-types.nix {pydantic = pydantic;};
  sigstore = python312Packages.callPackage ./sigstore.nix {
    importlib-resources = importlib-resources;
    pydantic = pydantic;
    sigstore-rekor-types = sigstore-rekor-types;
  };
  aiogithubapi = python312Packages.callPackage ./aiogithubapi.nix {sigstore = sigstore;};
in
  buildHomeAssistantComponent rec {
    owner = "UI-Lovelace-Minimalist";
    domain = "ui_lovelace_minimalist";
    version = "1.3.9";

    src = fetchFromGitHub {
      owner = "JosefKatic";
      repo = "UI";
      rev = "main";
      sha256 = "sha256-miERCRtDlr8uujYGuBK2Nqk9DbvrCWR2neXgi2+chZ4=";
    };

    dependencies = [
      python312Packages.aiofiles
      aiogithubapi
    ];
  }
