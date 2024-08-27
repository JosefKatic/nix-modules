{
  config,
  lib,
  ...
}: let
  cfg = config.device.core;
in {
  # Removes default packages like rsync, strace or perl
  # Taken from https://xeiaso.net/blog/paranoid-nixos-2021-07-18/
  options.device.core.disableDefaults = lib.mkOption {
    type = lib.types.bool;
    default = true;
    example = false;
  };

  config = lib.mkIf cfg.disableDefaults {
    environment.defaultPackages = lib.mkForce [];
    # TODO: Disable in future
    programs.nano.enable = true;
  };
}
