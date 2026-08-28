# 权限策略（agents/permissions.md）

本仓库对 AI agent 的权限策略。原则：**bash 默认 allow**（日常低风险命令不再逐个确认），敏感文件 deny，高危命令 ask。

行为规则见根目录 `AGENTS.md`；opencode 权限配置落地见 `home/programs/AI/opencode.nix`。

## 敏感文件（deny 读取与编辑）

| 模式 | 权限 |
|------|------|
| `secrets/**`（sops 加密机密） | deny |
| `*.key` / `*.pem` | deny |
| `*.env` / `*.env.*` | deny |
| `.ssh/**` `.gnupg/**` `.aws/**` `.kube/**` | deny |
| `~/.config/mihomo/**`（订阅 token） | deny |

## 高危命令（ask，需逐次确认）

| 命令/工具 | 原因 |
|-----------|------|
| `sudo *` | 提权操作 |
| `nh os switch/boot *`、`nixos-rebuild switch/boot *` | 切换系统 generation，影响启动 |
| `rm *` | 删除不可逆 |
| `vault-open` / `vault-close` / `cryptsetup *` | 操作加密盘（解锁密码是全部数据钥匙） |
| `sops *` | 编辑/解密机密（防明文泄漏） |
| `git push *`、`gh pr create/issue create/repo create` | 远程改写（推送到远端/建 PR） |
| `mount` / `umount` / `mkfs` / `fdisk` / `parted` / `dd` | 磁盘/分区操作 |
| `shutdown` / `reboot` / `poweroff` | 关机重启 |
| `env *` / `printenv *` | 可读取环境变量中的 API token 等凭据 |
| `task` / `external_directory` | 子代理/跨目录访问 |

## 落地方式

- **opencode 权限配置**：`home/programs/AI/opencode.nix` 的 `xdg.configFile."opencode/opencode.jsonc"`（home-manager 声明式，rebuild 后生效于 `~/.config/opencode/opencode.jsonc`）。
- **行为规则**：仓库根目录 `AGENTS.md`（opencode 等 agent 自动读取）。
- 新增高危命令/敏感文件时，同步更新本文件与 `opencode.nix` 两处。
