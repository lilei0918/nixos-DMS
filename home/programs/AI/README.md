# home/programs/AI

AI 工具集中目录。原则：**只装工具，provider/模型/凭据自行管理**（不进 Nix）。

- `zed.nix`     Zed 编辑器：声明式设置/插件/主题（Gruvbox Dark + `icons-modern-material` 图标），三栏布局（左 Project / 中 Editor / 右 Agent），ACP 链接 opencode（`opencode acp`，**勿用 `serve`**，那是 HTTP 服务器）
- `vscode.nix`  VSCodium（非 VSCode）：nix-ide/gitlens 等扩展，主题 Gruvbox Dark Medium，Nix LSP 用 nixd
- `opencode.nix` OpenCode：`opencode auth login` 管理凭据（切换 provider 无需改 Nix）
- `codex.nix`   Codex CLI（OpenAI coding agent）：`codex login` 认证；VSCodium 的 Codex 扩展走 PATH 里的 codex CLI
- `pi.nix`      Pi agent：`pi` 内 `/login` 认证（自动写入 `~/.pi/agent/auth.json`）

详见 `README.md`「七」AI 行。
