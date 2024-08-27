{
  config,
  lib,
  ...
}: let
  cfg = config.device.utils.virtualisation;
in {
  options.device.utils.virtualisation.docker = {
    enable = lib.mkEnableOption "Docker virtualisation";
  };

  config = lib.mkIf cfg.docker.enable {
    virtualisation.docker = {
      enable = true;
      storageDriver = "btrfs";
    };
  };
}
