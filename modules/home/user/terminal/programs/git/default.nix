{
  config,
  pkgs,
  ...
}: {
  home.packages = [pkgs.gh];

  programs.delta = {
    enable = true;
    options.${config.programs.matugen.variant} = true;
    enableGitIntegration = true;
  };

  programs.git = {
    enable = true;
    signing = {
      key = "0xBAD7648677C2B3C6";
      signer = "${config.programs.gpg.package}/bin/gpg2";
      signByDefault = true;
    };
    settings = {
      alias = {
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
      user = {
        name = "Josef Katič";
        email = "josef@joka00.dev";
      };
      feature.manyFiles = true;
      init.defaultBranch = "main";
      commit.gpgSign = true;
      diff.colorMoved = "default";
      merge.conflictstyle = "diff3";
    };
    lfs.enable = true;
  };
}
