{
  programs.tmux = {
    enable = true;

    mouse = true;

    historyLimit = 100000;

    clock24 = true;

    baseIndex = 1;

    extraConfig = ''
      set -g status-position bottom

      # vim操作
      setw -g mode-keys vi

      # 更快刷新
      set -sg escape-time 0
    '';
  };
}
