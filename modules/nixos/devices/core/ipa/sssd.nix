# Copy of the sssd module from Nixpkgs with some changes
{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkForce optionalString concatStringsSep toLower;
  cfg = config.security.ipa;
  hasOptinPersistence = config.environment.persistence ? "/persist";
  pyBool = x:
    if x
    then "True"
    else "False";

  ldapConf = pkgs.writeText "ldap.conf" ''
    # Turning this off breaks GSSAPI used with krb5 when rdns = false
    SASL_NOCANON    on

    URI ldaps://${cfg.server}
    BASE ${cfg.basedn}
    TLS_CACERT /etc/ipa/ca.crt
  '';
  nssDb =
    pkgs.runCommand "ipa-nssdb"
    {
      nativeBuildInputs = [pkgs.nss.tools];
    }
    ''
      mkdir -p $out
      certutil -d $out -N --empty-password
      certutil -d $out -A --empty-password -n "${cfg.realm} IPA CA" -t CT,C,C -i ${cfg.certificate}
    '';
in {
  services.sssd.config = mkForce ''
    [domain/${cfg.domain}]
    id_provider = ipa
    auth_provider = ipa
    access_provider = ipa
    chpass_provider = ipa

    ipa_domain = ${cfg.domain}
    ipa_server = _srv_, ${cfg.server}
    ipa_hostname = ${cfg.ipaHostname}

    cache_credentials = ${pyBool cfg.cacheCredentials}
    krb5_store_password_if_offline = ${pyBool cfg.offlinePasswords}
    ${optionalString ((toLower cfg.domain) != (toLower cfg.realm)) "krb5_realm = ${cfg.realm}"}

    dyndns_update = ${pyBool cfg.dyndns.enable}
    dyndns_iface = ${cfg.dyndns.interface}

    ldap_tls_cacert = /etc/ipa/ca.crt
    ldap_user_extra_attrs = mail:mail, sn:sn, givenname:givenname, telephoneNumber:telephoneNumber, lock:nsaccountlock
    ldap_user_ssh_public_key = ipaSshPubKey

    [sssd]
    services = nss, sudo, pam, ssh, ifp
    domains = ${cfg.domain}

    [nss]
    homedir_substring = /home

    [pam]
    pam_pwd_expiration_warning = 3
    pam_verbosity = 3

    [sudo]

    [autofs]

    [ssh]

    [pac]

    [ifp]
    user_attributes = +mail, +telephoneNumber, +givenname, +sn, +lock
    allowed_uids = ${concatStringsSep ", " cfg.ifpAllowedUids}
  '';
}
