{pkgs, ...}: {
  imports = [./udiskie ./auto-upgrade];
  home.packages = with pkgs; [coreutils inotify-tools];
}
