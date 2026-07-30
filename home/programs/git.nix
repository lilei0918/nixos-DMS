{
  config,
  pkgs,
  ...
}: {
  programs.git = {
    enable = true;

    userName = "lilei";
    userEmail = "lilei0918@gmail.com";

    lfs.enable = true;

    extraConfig = {
      init.defaultBranch = "main";

      pull.rebase = true;

      core = {
        editor = "vim";
        autocrlf = "input";
      };

      color.ui = "auto";

      diff.colorMoved = "default";

      merge.conflictstyle = "zdiff3";

      credential.helper = "store";
    };

    aliases = {
      st = "status";
      co = "checkout";
      br = "branch";
      lg = "log --oneline --graph --decorate";
    };
  };

  programs.git.delta = {
    enable = true;

    options = {
      side-by-side = true;
      navigate = true;
      line-numbers = true;
      syntax-theme = "Catppuccin Mocha";
    };
  };
}
