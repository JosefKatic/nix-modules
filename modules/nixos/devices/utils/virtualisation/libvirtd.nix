{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.device.utils.virtualisation;
in {
  options.device.utils.virtualisation.libvirtd = {
    enable = lib.mkEnableOption "Whether to enable libvirtd";
  };
  config = lib.mkIf cfg.libvirtd.enable {
    environment.systemPackages = [
      pkgs.virt-manager
      pkgs.virt-viewer
      pkgs.spice
      pkgs.spice-gtk
      pkgs.spice-protocol
      pkgs.win-virtio
      pkgs.win-spice
    ];

    virtualisation = {
      libvirtd = {
        enable = true;
        qemu = {
          swtpm.enable = true;
        };
      };
      spiceUSBRedirection.enable = cfg.libvirtd.enable;
    };
    services.spice-vdagentd.enable = cfg.libvirtd.enable;
    environment.persistence = lib.mkIf config.device.core.storage.enablePersistence {
      "/persist" = {
        directories = [
          "/var/lib/libvirt"
        ];
      };
    };
  };
}
