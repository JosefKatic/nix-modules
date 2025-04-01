{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.user.desktop.programs.editors.vscode;
in {
  options = {
    user.desktop.programs.editors = {
      vscode = {
        enable = lib.mkEnableOption "Enable VSCode";
        package = lib.mkOption {
          type = lib.types.package;
          default = pkgs.vscode;
          description = "Enable VS Code";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.vscode = {
      enable = cfg.enable;
      profiles.default = {
        enableExtensionUpdateCheck = true;
      };
      mutableExtensionsDir = true;
    };
  };
}
