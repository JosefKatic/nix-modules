{
  config,
  lib,
  pkgs,
  options,
  self,
  ...
}: {
  options.device.server.services.deploy = {
    enable = lib.mkEnableOption "Enable deploy command and add users";
  };

  config = lib.mkIf config.device.server.services.deploy.enable {
    # environment.persistence = lib.mkIf config.device.core.storage.enablePersistence {
    #   "/persist" = {
    #     directories = [
    #       "/tmp/deploy"
    #     ];
    #   };
    # };

    # environment.sessionVariables = {
    #   "DEPLOY_FLAKE" = "/var/deploy/.nix-config-next";
    # };

    # environment.systemPackages = [
    #   pkgs.deploySystem
    #   self.packages.${pkgs.system}.prefetchConfig
    # ];
  };
}
