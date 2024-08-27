{
  lib,
  config,
  ...
}: {
  imports = [
    ./legacy.nix
    ./uefi.nix
    ./quietboot.nix
  ];
}
