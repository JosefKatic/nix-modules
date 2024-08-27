{lib, ...}: {
  options.device = {
    type = lib.mkOption {
      type = lib.types.enum ["desktop" "server" "laptop"];
      example = "laptop";
    };
    virtualized = lib.mkEnableOption "Enable virtualized hardware support";
  };
}
