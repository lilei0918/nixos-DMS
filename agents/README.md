# agents

本目录说明本仓库给 AI agent（opencode / hermes 等）的「规则 + 权限」配套（思路借鉴 ryan4yin-nix-config 的 `agents/` 目录）。

- `permissions.md` — 权限策略说明：敏感文件 deny、命令 allow/ask 清单。
- 行为规则在仓库根目录 `AGENTS.md`。
- opencode 权限配置在 `home/programs/AI/opencode.nix`（home-manager 声明式，落地到 `~/.config/opencode/opencode.jsonc`）。

本仓库不使用符号链接分发脚本（install-rules.py 那套）：配置统一由 Home Manager 声明式管理，规则统一放在仓库根目录供各 agent 就地读取。
