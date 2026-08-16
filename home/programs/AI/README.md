# home/programs/AI

AI 编码工具。原则：**只装工具，provider/模型/凭据自行管理**（不进 Nix）。

- `zed.nix`     Zed 编辑器：声明式设置/插件/主题（macOS Classic 亮暗自动切换），ACP 链接 opencode（`opencode acp`，**勿用 `serve`**，那是 HTTP 服务器）
- `opencode.nix` OpenCode：`opencode auth login` 管理凭据（切换 provider 无需改 Nix）
- `pi.nix`      Pi agent：`pi` 内 `/login` 认证（自动写入 `~/.pi/agent/auth.json`）

详见 `README.md`「七」AI 行。
