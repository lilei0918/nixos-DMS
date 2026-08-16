# home/niri

Niri 窗口管理器配置。`default.nix` 用 `//` 合并四个文件。

- `default.nix`  入口：`settings // keybinds // rules // autostart`
- `settings.nix` 核心：命名工作区（`1-browser` / `2-note` / `3-code`）、布局、输入、输出 `eDP-1`、环境变量
- `keybinds.nix` 快捷键：`super+return` alacritty、`super+d` walker 等；截图用 **niri 内置动作**（`Print` / `Alt+Print` / `Ctrl+Print`，保存到 `~/Pictures/Screenshots/`）
- `rules.nix`    窗口规则：圆角 10/10/5/5、工作区分派、浮动类（QQ / telegram / hermes...）、SiYuan 独占 note 列
- `autostart.nix` 自启动：xwayland-satellite、polkit、fcitx5、blueman-applet、延迟 QQ

注意：`open-on-workspace` 必须先在此声明工作区；`home.nix` 用 `niri-stable` 包覆盖（libdisplay-info pin）。详见 `README.md`「六」。
