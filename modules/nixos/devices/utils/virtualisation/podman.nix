{
  config,
  lib,
  ...
}: let
  cfg = config.device.utils.virtualisation;
in {
  options.device.utils.virtualisation.podman = {
    enable = lib.mkEnableOption "Docker virtualisation";
  };

  config = lib.mkIf cfg.docker.enable {
    virtualisation.podman = {
      enable = true;
    };
  };
}
