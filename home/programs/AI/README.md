# home/programs/AI

AI 工具集中目录。原则：**只装工具，provider/模型/凭据自行管理**（不进 Nix）；
例外：Hermes Agent 是系统服务，其 model/provider 设置需声明式管理（见下）。

- `zed.nix`     Zed 编辑器：声明式设置/插件/主题（macOS Classic 亮暗自动切换），ACP 链接 opencode（`opencode acp`，**勿用 `serve`**，那是 HTTP 服务器）
- `opencode.nix` OpenCode：`opencode auth login` 管理凭据（切换 provider 无需改 Nix）
- `codex.nix`   Codex CLI（OpenAI coding agent）：`codex login` 认证；VSCodium 的 Codex 扩展走 PATH 里的 codex CLI
- `pi.nix`      Pi agent：`pi` 内 `/login` 认证（自动写入 `~/.pi/agent/auth.json`）
- `hermes.nix`  Hermes Desktop（home-manager）：桌面入口 + CLI/GUI 安装
- `hermes-service.nix`  Hermes Agent 系统服务（**NixOS 模块**，经 `hosts/legion/configuration.nix` 导入）：systemd 网关、model/provider 设置、sops 机密模板。与 hermes.nix 物理同处便于集中管理

详见 `README.md`「七」AI 行、「五」Hermes Agent 专节。
