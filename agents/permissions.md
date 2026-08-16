# 权限策略（agents/permissions.md）

本仓库对 AI agent 的权限策略。原则：**默认 ask**，只放行只读/安全检查类操作；敏感文件与高风险命令必须确认。

行为规则见根目录 `AGENTS.md`；opencode 权限配置落地见 `home/programs/AI/opencode.nix`。

## 敏感文件（deny 读取）

| 模式 | 权限 |
|------|------|
| `secrets/**`（sops 加密机密） | deny |
| `*.key` / `*.pem` | deny |
| `*.env` / `*.env.*` | deny |
| `.ssh/**` `.gnupg/**` `.aws/**` `.kube/**` | deny |
| `~/.config/mihomo/**`（订阅 token） | deny |

## 放行（allow，无需确认）

- **只读 Nix**：`nix eval/build/flake*/store*/search/doctor`、`nixos-rebuild build`、`nh os test`、`alejandra`、`statix check`、`deadnix`
- **只读 git / gh**：`git status/diff/log/show/branch/remote/tag/blame/reflog/stash list/lfs`、`gh repo/issue/pr view|list`、`gh api/search`
- **系统诊断（只读）**：`lsblk` `df` `free` `uptime` `uname` `lspci` `lsusb` `sensors` `lsof` `systemctl status/list-*/show` `journalctl`
- **常规读写工具**：`rg` `fd` `ls` `cat` `head` `tail` `wc` `find` `which` `echo` `pwd` `date` `env` `printenv` `file` `stat` `du` `tree` `bat` `eza` `jq` `yq` `mkdir` `rmdir` `grep` `cp` `mv` `chmod`
- **工具**：`read` `glob` `grep` `edit` `lsp` `skill` `question` `todowrite` `webfetch`

## 必须确认（ask）

| 命令/工具 | 原因 |
|-----------|------|
| `sudo *` | 提权操作，需逐次确认 |
| `nh os switch *` / `nh os boot *` | 切换系统 generation，影响启动 |
| `vault-open` / `vault-close` / `cryptsetup *` | 操作加密盘（解锁密码是全部数据钥匙） |
| `sops *` | 编辑/解密机密（防明文泄漏） |
| `rm *` / `rm -rf *` | 删除不可逆 |
| `task` / `external_directory` | 子代理/跨目录访问 |

## 落地方式

- **opencode 权限配置**：`home/programs/AI/opencode.nix` 的 `xdg.configFile."opencode/opencode.jsonc"`（home-manager 声明式，rebuild 后生效于 `~/.config/opencode/opencode.jsonc`）。
- **行为规则**：仓库根目录 `AGENTS.md`（opencode 等 agent 自动读取）。
- 新增高危命令/敏感文件时，同步更新本文件与 `opencode.nix` 两处。
