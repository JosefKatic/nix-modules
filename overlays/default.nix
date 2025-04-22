{
  inputs,
  lib,
  ...
}: {
  flake.overlays = let
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
            --subst-var-by bind ${final.bind.dnsutils} \
            --subst-var-by curl ${final.curl} \
            --subst-var-by kerberos ${final.kerberos} \
            --subst-var-by sssd ${final.sssd}
        '';
      });
    };
  in {
    joka00-modules = lib.composeManyExtensions [
      inputs.nix-minecraft.overlay
      patchFreeIPA
    ];
  };
}
