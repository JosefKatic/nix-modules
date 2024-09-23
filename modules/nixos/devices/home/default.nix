{
  config,
  lib,
  pkgs,
  utils,
  ...
}: let
  inherit (config.device) home;
  inherit (lib) types mkOption mkMerge optional;
in {
  options.device.home = {
    users = mkOption {
      type = types.listOf types.str;
    };
  };
}
