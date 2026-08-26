{
  pkgs,
  myvars,
  ...
}: {
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

      # 仅首次设置 universal 变量（之后由 fish 持久化，避免每次启动重写）
      set -q fish_history; or set -U fish_history main

    '';

    # =============================
    # Alias
    # =============================

    shellAliases = {
      # =====================
      # Nix
      # =====================

      rebuild = "nh os switch ${myvars.repoDir}#${myvars.flakeName}";

      nix-test = "nh os test ${myvars.repoDir}#${myvars.flakeName}";

      boot = "nh os boot ${myvars.repoDir}#${myvars.flakeName}";

      rollback = "sudo nixos-rebuild switch --rollback";

      cleanup = "sudo nix-collect-garbage --delete-older-than 14d";

      check = "nix flake check ${myvars.repoDir}";

      update = "nix flake update ${myvars.repoDir}";

      fmt = "alejandra ${myvars.repoDir}";

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


      # ⚠️ starship / direnv 的初始化由 HM 模块自动注入
      # （programs.starship.enableFishIntegration、programs.direnv 默认开启），
      # 手动 source 会重复初始化，勿加回：
      #   starship init fish | source
      #   direnv hook fish | source
      # ⚠️ fzf 快捷键由 fzf-fish 插件提供，手动 `fzf --fish | source` 会重复绑定 Ctrl-R


      # zoxide

      zoxide init fish | source


      # 快捷目录

      alias dl="cd ~/Downloads"
      alias docs="cd ~/Documents"
      # alias dev="cd ~/Dev"   # 目录不存在，先注释（需要时创建 ~/Dev 再启用）
      alias dots="cd ~/nixos-DMS"
      alias pics="cd ~/Pictures"
      # alias vids="cd ~/Videos" # 目录不存在，先注释（需要时创建 ~/Videos 再启用）


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
