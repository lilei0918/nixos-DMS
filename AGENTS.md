# AGENTS.md — 本仓库 AI 助手行为规则

本文件是 `nixos-DMS`（NixOS 配置仓库）对 AI agent（opencode / hermes 等）的行为基线。
领域知识（硬件、目录结构、各模块详解、维护流程、排障）见仓库根目录 `README.md` 及各子目录 `README.md`。

## 1. 指令优先级

按以下顺序应用指令：

1. 运行时系统/开发者指令
2. 用户本次任务要求
3. 本仓库规则（本文件 + `README.md` + 各子目录 `README.md`）
4. 全局规则

规则冲突时以高优先级为准，并简要说明冲突。

## 2. 硬性安全边界（禁止）

- 禁止读写工作区以外的文件（除非用户明确指定运维必需路径，如 `~/.config`、`~/.local/bin`）。
- 禁止未明确要求就执行远程改写操作（`git push`、`gh` 创建 PR/Issue 等）。
- 禁止未明确要求就执行破坏性/不可逆操作（`rm -rf`、磁盘/分区操作、`cryptsetup` 破坏性用法等）。
- 禁止把机密写入任何被 git 跟踪的文件。
- 禁止改动 `/home/lilei` 之外的系统关键文件（除非在配置仓库范围内的 rebuild 流程中）。

## 3. 机密处理（sops / age）

- 本仓库机密在 `secrets/secrets.yaml`（sops age 加密），**禁止直接打开或解密查看内容**。
- 修改机密用 `sops secrets/secrets.yaml`（明文输入、保存自动加密），禁止写明文。
- 信任根 `/etc/sops/age/keys.txt`：绝不读取其内容、绝不提交 git。
- 回答中不复述解密出的密钥/口令/证书私钥。
- 需要引用机密值时，用 `config.sops.placeholder."<name>"` 或 `config.sops.secrets."<name>".path` 等声明式写法，不要自行 `sops -d` 打印。

## 4. 改动纪律

- 只在请求范围内改动；不顺手重构无关区域。
- 保持 diff 最小、可审查；相关改动分组提交。
- 不声称做了未实际运行的验证。

## 5. 工具默认值

- Nix 配置一律经 flake。改动流程（本仓库惯例）：
  `cd /home/lilei/nixos-DMS` → `alejandra .`（格式化）→ `nix flake check`（eval 测试 + pre-commit）→ `git add -A && git commit -m "before switch"` → `nh os switch .#legion`（**不要手动加 sudo**，nh 会自动提权）。
- 搜索优先结构化工具（glob / grep / rg / fd）。
- 装包只经 nixpkgs / NUR / 现有 flake inputs，不引入其它安装器。
- 命令速查见 `README.md`「十、常用命令速查」。

## 6. 环境

- 主机：Lenovo Legion R7000P 2021；NixOS（主机名 `nixos`，flake 名 `legion`）+ Arch + Win11 多系统引导。
- 会话：niri（Wayland）桌面；终端常用 fish，默认登录 shell zsh。
- 挂载点：数据盘 `/run/media/lilei/DATATB`（ntfs3 自动挂载）、加密盘 `/mnt/vault`（`vault-open` / `vault-close` 手动解锁）。
- 涉及 `systemctl` / `nh` / `sudo` / 加密盘的操作默认需用户确认（详见 `agents/permissions.md`）。

## 7. 沟通

- 用当前对话语言作答（默认中文）；代码、命令、标识符、注释用英文。
- 简洁、具体、可执行；引用具体文件路径与配置示例。
- 执行会改系统的命令（`nh os switch`、`vault-open` 等）前，先说明命令与影响再执行。

## 8. 项目叠加

- 子目录 `README.md` 与模块内注释可进一步细化规则，但不得弱化本文件的硬性边界。
