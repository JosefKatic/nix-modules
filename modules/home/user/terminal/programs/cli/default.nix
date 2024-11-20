{pkgs, ...}: {
  home.packages = with pkgs; [
    # archives
    zip
    unzip
    unrar

    # misc
    libnotify

    # utils
    du-dust
    duf
    fd
    file
    jaq
    ripgrep
  ];

  programs = {
    eza.enable = true;
    ssh = {
      enable = true;
      extraConfig = ''
        ControlPath ~/.ssh/sockets/%r@%h:%p
      '';
    };
    bash.enable = true;
  };
}
