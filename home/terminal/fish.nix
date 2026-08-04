{pkgs, ...}: {
  programs.fish = {
    enable = true;

    # =============================
    # 自动补全
    # =============================

    generateCompletions = true;

    # =============================
    # 历史记录
    # =============================

    shellInit = ''

      set -U fish_history main

    '';

    # =============================
    # Alias
    # =============================

    shellAliases = {
      # =====================
      # Nix
      # =====================

      rebuild = "nh os switch /home/lilei/nixos-DMS#legion";

      nix-test = "nh os test /home/lilei/nixos-DMS#legion";

      boot = "nh os boot /home/lilei/nixos-DMS#legion";

      rollback = "sudo nixos-rebuild switch --rollback";

      cleanup = "sudo nix-collect-garbage --delete-older-than 14d";

      check = "nix flake check /home/lilei/nixos-DMS";

      update = "nix flake update /home/lilei/nixos-DMS";

      fmt = "alejandra /home/lilei/nixos-DMS";

      # =====================
      # Git
      # =====================

      g = "git";

      gs = "git status";

      ga = "git add -A";

      gd = "git diff";

      gl = "git log --oneline --graph --decorate";

      gp = "git push";

      # =====================
      # System
      # =====================

      c = "clear";

      e = "exit";

      # =====================
      # tools
      # =====================

      cat = "bat";

      ls = "eza";

      ll = "eza -lah";
    };

    # =============================
    # Fish 初始化
    # =============================

    interactiveShellInit = ''

      set fish_greeting


      # Starship

      starship init fish | source


      # direnv

      direnv hook fish | source


      # zoxide

      zoxide init fish | source


      # fzf

      fzf --fish | source


      # 快捷目录

      alias dl="cd ~/Downloads"
      alias docs="cd ~/Documents"
      alias dev="cd ~/Dev"
      alias dots="cd ~/nixos-DMS"
      alias pics="cd ~/Pictures"
      alias vids="cd ~/Videos"


    '';
  };

  # =============================
  # Fish 插件
  # =============================

  programs.fish.plugins = [
    {
      name = "fzf-fish";
      src = pkgs.fishPlugins.fzf-fish;
    }
  ];
}
