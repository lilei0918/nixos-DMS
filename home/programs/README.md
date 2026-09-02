# home/programs

用户级应用软件包与配置（经 `hosts/legion/home.nix` 导入）。

- `AI/`            zed / opencode / pi / hermes（Hermes 含桌面入口 + 系统服务）四个 AI 工具
- `btop.nix`       系统监控（desktop entry 走 `ghostty -e btop`）
- `chrome.nix`     Google Chrome：Wayland + VA-API 硬解（包本体 + 启动参数 commandLineArgs + 环境变量均在此）
- `dconf.nix`      GNOME dconf 主题设置
- `dev.nix`        全局开发工具链（uv / python / nodejs / pnpm / just / gh / yq）
- `fastfetch.nix`  系统信息（logo 用 `assets/icons/logo.png`）
- `git.nix`        git + delta（user 走 `myvars`）
- `rime.nix`       rime-ice 方案 + fcitx 环境变量（rebuild 后需 `fcitx5-remote -r` 部署）
- `theme.nix`      GTK3 WhiteSur / Qt gtk3 / macOS-White 光标（GTK4 走系统默认）
- `thunar.nix`     文件管理器（配置走 HM `xfconf.settings` 模块）
- `vscode/`        VSCodium + nixd 扩展
- `walker.nix`     walker 启动器 + elephant 剪贴板依赖

> Hermes Desktop 的 home-manager 模块与 hermes-agent 系统服务已随其他 AI 工具集中到 `AI/`。

新增软件流程见 `README.md`「八」；各文件要点见 `README.md`「七」。
