{
  config,
  lib,
  ...
}: {
  options.device.build = lib.mkOption {
    type = lib.types.str;
    default = "0";
    description = ''
      Enable building of the device.
    '';
  };

  config = lib.mkIf (config.device.build != "0") {
    environment.etc = {
      buildID = {
        text = config.device.build;
        mode = "0440";
      };
    };
  };
}
