# home

用户级配置（Home Manager，仅用户 `lilei`），入口为 `hosts/legion/home.nix` 的 `imports`。

- `niri/`      Niri 窗口管理器（settings / keybinds / rules / autostart 四文件合并）
- `terminal/`  alacritty / ghostty / fish / zsh / starship / tmux
- `programs/`  应用软件包与配置（浏览器、AI 工具、编辑器、Rime 等）

新增用户软件：在 `home/programs/` 建 `<name>.nix`，再到 `hosts/legion/home.nix` 的 `imports` 引用。
各文件要点见 `README.md`「七」。
