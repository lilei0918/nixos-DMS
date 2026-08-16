# home/terminal

终端相关配置。

- `alacritty.nix` 主终端：JetBrainsMono NF、Monokai Pro 配色、shell=fish
- `ghostty.nix`   次选终端：monokai-pro 主题、GTK tabs bottom
- `fish.nix`      fish：Nix 别名（`rebuild` / `nix-test` / `boot` / `check` / `update` / `fmt`，绝对路径）、g* git 别名、fzf-fish 插件
- `zsh.nix`       zsh：oh-my-zsh、同名 Nix 别名、`cd=z`
- `starship.nix`  prompt（极简 format）
- `tmux.nix`      mouse、vi 模式键、历史 10 万

别名全部用绝对路径（`myvars.repoDir`），任意目录可用。详见 `README.md`「七」。
