{
  inputs,
  lib,
  ...
}: {
  flake.overlays = rec {
    joka00-modules = lib.composeManyExtensions [
      inputs.nix-minecraft.overlay
      patchFreeIPA
    ];
    patchFreeIPA = final: prev: {
      freeipa = prev.freeipa.overrideAttrs (oldAttrs: {
        patches =
          (oldAttrs.patches or [])
          ++ [
            ./freeipa-passkeys.diff
          ];
        postPatches = ''
          patchShebangs makeapi makeaci install/ui/util

          substituteInPlace ipasetup.py.in \
            --replace 'int(v)' 'int(v.replace("post", ""))'

          substituteInPlace client/ipa-join.c \
            --replace /usr/sbin/ipa-getkeytab $out/bin/ipa-getkeytab

          substituteInPlace ipaplatform/nixos/paths.py \
            --subst-var out \
            --subst-var-by bind ${prev.bind.dnsutils} \
            --subst-var-by curl ${prev.curl} \
            --subst-var-by sssd ${fiprevnal.sssd} \
            --subst-var-by kerberos ${prev.krb5}
        '';
      });
    };
  };
}
