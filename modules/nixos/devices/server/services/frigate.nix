{
  config,
  lib,
  ...
}: let
  inherit (lib) types mkEnableOption mkIf;
  cfg = config.device.server.services;
in {
  options.device.server.services.frigate = {
    enable = mkEnableOption "Enable frigate server";
  };

  config = mkIf cfg.frigate.enable {
    services.frigate = {
      enable = true;
      hostname = "localhost";
      settings = {
        record = {
          enabled = false;
          retain = {
            days = 2;
            mode = "all";
          };
        };

        cameras = {
          "back1" = {
            ffmpeg.inputs = [
              {
                path = "rtsp://10.34.70.197";
                roles = [
                  "detect"
                ];
              }
            ];
          };
        };
      };
    };
  };
}
