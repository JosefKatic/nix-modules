{
  inputs,
  lib,
  ...
}: {
  flake.overlays = {
    joka00-modules = lib.composeManyExtensions [
      inputs.nix-minecraft.overlay
    ];
  };
}
