{
  config,
  lib,
  ...
}: let
  cfg = config.device.core.shells;
in {
  options.device.core.shells.zsh = {
    enable = lib.mkEnableOption "Enable zsh shell";
  };

  config = lib.mkIf cfg.zsh.enable {
    programs.zsh = {
      autosuggestions.enable = true;
      syntaxHighlighting = {
        enable = true;
        patterns = {"rm -rf *" = "fg=black,bg=red";};
        styles = {"alias" = "fg=magenta";};
        highlighters = ["main" "brackets" "pattern"];
      };
    };
  };
}
