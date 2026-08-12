{
  config,
  myvars,
  ...
}: {
  programs.zsh = {
    enable = true;

    enableCompletion = true;

    autocd = true;

    # =============================
    # History
    # =============================

    history = {
      expireDuplicatesFirst = true;

      ignoreDups = true;

      ignoreSpace = true;

      save = 100000;

      size = 100000;

      extended = true;

      share = true;

      path = "${config.xdg.dataHome}/zsh/history";
    };

    # =============================
    # Plugins
    # =============================

    syntaxHighlighting.enable = true;

    autosuggestion.enable = false;

    oh-my-zsh = {
      enable = true;

      plugins = [
        "git"

        "sudo"

        "colored-man-pages"

        "extract"
      ];
    };

    # =============================
    # Alias
    # =============================

    shellAliases = {
      # Nix

      rebuild = "nh os switch ${myvars.repoDir}#${myvars.flakeName}";

      test = "nh os test ${myvars.repoDir}#${myvars.flakeName}";

      boot = "nh os boot ${myvars.repoDir}#${myvars.flakeName}";

      rollback = "sudo nixos-rebuild switch --rollback";

      cleanup = "sudo nix-collect-garbage --delete-older-than 14d";

      check = "nix flake check ${myvars.repoDir}";

      update = "nix flake update ${myvars.repoDir}";

      fmt = "alejandra ${myvars.repoDir}";

      # Git

      g = "git";

      gs = "git status";

      ga = "git add -A";

      gd = "git diff";

      gl = "git log --oneline --graph --decorate";

      gp = "git push";

      # System

      c = "clear";

      e = "exit";

      ll = "eza -lah";

      ls = "eza";
    };

    # =============================
    # Init
    # =============================

    initContent = ''

      # Starship

      eval "$(starship init zsh)"



      # direnv

      eval "$(direnv hook zsh)"



      # zoxide

      eval "$(zoxide init zsh)"



      # better cd

      alias cd=z

    '';
  };
}
