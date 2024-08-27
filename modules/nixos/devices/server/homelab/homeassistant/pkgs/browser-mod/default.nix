{
  stdenv,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  home-assistant,
  python312Packages,
}:
buildHomeAssistantComponent rec {
  owner = "thomasloven";
  domain = "browser_mod";
  version = "2.3.0";

  src = fetchFromGitHub {
    owner = owner;
    repo = "hass-browser_mod";
    rev = "refs/tags/${version}";
    sha256 = "sha256-32uVZyrolctieBOEY5AdN1SR08gS8OGi/ooA8S9/SN4=";
  };
}
