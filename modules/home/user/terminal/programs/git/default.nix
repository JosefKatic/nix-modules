{
  config,
  pkgs,
  ...
}: {
  home.packages = [pkgs.gh];

  programs.git = {
    enable = true;

    delta = {
      enable = true;
      options.${config.programs.matugen.variant} = true;
    };

    extraConfig = {
      diff.colorMoved = "default";
      merge.conflictstyle = "diff3";
    };

    aliases = {
      a = "add";
      b = "branch";
      c = "commit";
      ca = "commit --amend";
      cm = "commit -m";
      co = "checkout";
      d = "diff";
      ds = "diff --staged";
      p = "push";
      pf = "push --force-with-lease";
      pl = "pull";
      l = "log";
      r = "rebase";
      s = "status --short";
      ss = "status";
      forgor = "commit --amend --no-edit";
      graph = "log --all --decorate --graph --oneline";
      oops = "checkout --";
    };

    ignores = ["*~" "*.swp" "*result*" ".direnv" ".idea" ".vscode" "node_modules"];
    userName = "Josef Katič";
    userEmail = "josef@joka00.dev";
    signing = {
      key = "0xBAD7648677C2B3C6";
      signer = "${config.programs.gpg.package}/bin/gpg2";
      signByDefault = true;
    };
    extraConfig = {
      feature.manyFiles = true;
      init.defaultBranch = "main";
      commit.gpgSign = true;
    };
    lfs.enable = true;
  };
}
