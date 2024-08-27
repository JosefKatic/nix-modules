{pkgs, ...}: {
  imports = [./udiskie];
  home.packages = with pkgs; [coreutils inotify-tools];
}
