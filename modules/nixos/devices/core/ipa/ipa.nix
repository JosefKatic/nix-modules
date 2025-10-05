{pkgs, ...}: {
  security.ipa = {
    enable = true;
    server = "ipa.internal.joka00.dev";
    offlinePasswords = true;
    cacheCredentials = true;
    realm = "INTERNAL.JOKA00.DEV";
    domain = "internal.joka00.dev";
    basedn = "dc=internal,dc=joka00,dc=dev";
    certificate = pkgs.fetchurl {
      url = "http://ipa.internal.joka00.dev/ipa/config/ca.crt";
      sha256 = "sha256-rCbcfsQilbXNpBOXq8alvu2XK2SoVcC96kYk5GDEndw=";
    };
  };
  # To enable homedir on first login, with login, sshd, and sssd
  security.pam.services.sss.makeHomeDir = true;
  security.pam.services.sshd.makeHomeDir = true;
  security.pam.services.login.makeHomeDir = true;
}
