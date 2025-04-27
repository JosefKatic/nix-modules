{lib, ...}: {
  options.company.autoUpgrade = {
    operation = lib.mkOption {
      type = lib.types.enum ["switch" "boot"];
      default = "switch";
    };
    dates = lib.mkOption {
      type = lib.types.str;
      default = "hourly";
      example = "daily";
    };
    instance = lib.mkOption {
      type = lib.types.str;
      default = "https://hydra.joka00.dev";
    };
    project = lib.mkOption {
      type = lib.types.str;
      default = "nix-config";
    };
    jobset = lib.mkOption {
      type = lib.types.str;
      default = "main";
    };
    oldFlakeRef = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "self";
      description = ''
        Current system's flake reference

        If non-null, the service will only upgrade if the new config is newer
        than this one's.
      '';
    };
  };
}
