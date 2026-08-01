{
  programs.git = {
    enable = true;

    lfs.enable = true;

    settings = {
      user = {
        name = "lilei";
        email = "lilei0918@gmail.com";
      };

      init.defaultBranch = "main";

      pull.rebase = true;

      core = {
        editor = "vim";
        autocrlf = "input";
      };

      color.ui = "auto";

      diff = {
        colorMoved = "default";
      };

      merge = {
        conflictstyle = "zdiff3";
      };

      alias = {
        st = "status";
        co = "checkout";
        br = "branch";
        lg = "log --oneline --graph --decorate";
      };
    };
  };

  programs.delta = {
    enable = true;

    enableGitIntegration = true;

    options = {
      side-by-side = true;

      navigate = true;

      line-numbers = true;

      syntax-theme = "Catppuccin Mocha";
    };
  };
}
