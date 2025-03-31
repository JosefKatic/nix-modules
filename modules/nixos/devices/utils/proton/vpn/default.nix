{
  config,
  lib,
  ...
}: let
  cfg = config.device;
in {
  options.device.utils.proton.vpn.enable = lib.mkEnableOption "Enable Proton VPN";

  config = {environment.systemPackages = with pkgs; [protonvpn-cli];};
}
