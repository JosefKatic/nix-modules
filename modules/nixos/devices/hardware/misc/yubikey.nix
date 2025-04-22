{
  self,
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.device.hardware.misc;
in {
  options.device.hardware.misc.yubikey = {
    enable = lib.mkEnableOption "Whether to enable yubikey support";
  };
  config = lib.mkIf cfg.yubikey.enable {
    services.pcscd.enable = true;

    /*
       sops.secrets.u2f-key = {
      sopsFile = "${self}/secrets/admin/secrets.yaml";
      neededForUsers = true;
    };

    security.pam.u2f = {
      enable = true;
      settings = {
        interactive = true;
        authFile = "${config.sops.secrets.u2f-key.path} [cue_prompt=🔑 Tap the key...]";
        cue = true;
      };
    };
    security.pam.services = {
      login.u2fAuth = true;
      sudo.u2fAuth = true;
    };
    */
  };
}
