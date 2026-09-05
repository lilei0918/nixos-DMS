# 备忘录（命令速查）

> 本机：NixOS，主机名 `nixos`，flake 配置名 **`legion`**——所有 rebuild/switch 用 `.#legion`。
> `nh` 会自动提权，**不要**在 `nh` 前面加 `sudo`。详细说明见根目录 `README.md`。

---

## 一、最常用（忘了先看这里）

| 想做什么 | 命令 |
|----------|------|
| 重建系统 | `rebuild` 或 `nh os switch .#legion` |
| 只测试不切换 | `nix-test`（fish / zsh 同名）或 `nh os test .#legion` |
| 开加密盘 | `sudo vault-open` |
| 关加密盘 | `sudo vault-close` |
| 备份信任根/凭据 | `sudo bash scripts/backup-credentials.sh` |
| 编辑机密 | `sops secrets/secrets.yaml` |
| 查看系统信息 | `fastfetch` |

fish/zsh 别名（任意目录可用，绝对路径）：`rebuild` `test`/`nix-test` `boot` `rollback` `cleanup` `update` `check` `fmt`。

---

## 二、Nix 构建与系统

| 操作 | 命令 |
|------|------|
| 重建 | `sudo nixos-rebuild switch --flake .#legion` 或 `nh os switch .#legion` |
| 测试 | `sudo nixos-rebuild test --flake .#legion` 或 `nh os test .#legion` |
| 以新 generation 启动 | `nh os boot .#legion` 或 `boot` |
| 回滚 | `sudo nixos-rebuild switch --rollback` 或 `rollback` |
| 校验（eval 测试 + pre-commit） | `nix flake check` |
| 进入开发环境 | `nix develop`（自动装 git pre-commit 钩子） |
| 格式化 | `alejandra .` 或 `fmt` |
| 更新所有 inputs | `nix flake update` 或 `update` |
| 更新单个 input | `nix flake lock --update-input <name>` |
| 查看 generations | `sudo nixos-rebuild list-generations` |
| 清理垃圾 | `sudo nix-collect-garbage -d` 或 `cleanup`（保留 14 天） |
| 搜索包 | `nix search nixpkgs <pkg>` |
| 查看系统包 | `nix-store -q --references /run/current-system/sw` |
| 查看用户包 | `home-manager packages` |
| 查看 flake 元数据 | `nix flake metadata` |
| 版本/内核 | `nixos-version`、`uname -r` |

提交前惯例：`alejandra .` → `nix flake check` → `git add -A && git commit -m "before switch"` → `nh os switch .#legion`。

---

## 三、每周升级（定期维护）

> 建议每周末跑一遍。详细说明见 README「九、系统更新与回滚」。

**流程**：
```bash
# 1. 先保存当前状态（未提交的改动先落地）
git add -A && git commit -m "before update"
#    （必要时先备份凭据：sudo bash scripts/backup-credentials.sh）

# 2. 更新 flake 锁（只更新非 pin 的 input）
nix flake update            # 或别名：update

# 3. 校验 + 测试构建（不切换）
nix flake check             # eval 测试 + pre-commit（alejandra/typos）
nh os test .#legion         # 或 nix-test：构建并激活，不改启动项

# 4. 确认无误后正式切换
nh os switch .#legion       # 或 rebuild

# 5. 提交锁文件并推送
git add flake.lock && git commit -m "update inputs" && git push

# 6.（可选）清理旧 generation
cleanup

# 7. 升级了内核/引导则重启一次
reboot
```

**升级后检查**：
```bash
fastfetch                          # 版本/内核
uname -r                           # 新内核
systemctl is-active hermes-agent vaultwarden.service daed greetd
```

**⚠️ 本仓库特有的注意**：
- **被 pin 的 input 不会随 `nix flake update` 更新**，需手动改 `flake.nix`：
  - `hermes-agent`：nixpkgs pin 在 `624af66`（npm 依赖命中旧缓存，别轻易升）
  - `daeuniverse`：nixpkgs pin 在 `b12141ef`（pnpm 10.x）
  - 升级它们前先确认上游已兼容（pnpm 11 等），并验证能构建
  - ⚠️ `niri` 已不再 pin（2026-08-30 改）：改用 nixpkgs `pkgs.niri`，配置为手写 KDL（`home/niri/conf/*.kdl`）
- 大升级后建议重启，确认新 generation 能被引导（NixOS GRUB 主引导，GRUB 菜单里可选旧 generation 回滚）

**坏了的回滚**：
- 启动时在 GRUB 菜单选旧 generation；或 `rollback`

**常见升级踩坑**：
| 现象 | 处理 |
|------|------|
| daed/daeuniverse 构建失败 | nixpkgs 升级可能动了 pnpm 版本；确认 `daeuniverse` 的 pin 没被破坏，必要时临时启用 garnix 缓存或本地编译 |
| niri 配置解析失败 | 用 `niri validate` 校验 `~/.config/niri/config.kdl`；niri 随 nixpkgs 升级，KDL 语法若有破坏性变更需同步改 `home/niri/conf/` |
| hermes 构建变慢/重新下 npm 依赖 | 它的 nixpkgs pin 在 624af66（命中旧缓存）；别轻易升级该 pin，否则全量重下 |
| 新 generation 无法引导 | GRUB 选旧 generation 回滚，修复后再切 |

---

## 四、加密盘 /mnt/vault（LUKS 20G，nvme1n1p3）

| 操作 | 命令 |
|------|------|
| 解锁 + 挂载 | `sudo vault-open` |
| 卸载 + 锁 | `sudo vault-close` |
| 查看状态 | `cryptsetup status vault`、`lsblk /dev/nvme1n1p3` |
| 查占用进程 | `lsof +D /mnt/vault` |
| 未部署时的等价命令 | `sudo nix-shell -p cryptsetup --run 'cryptsetup open UUID=86c742fc-8de5-4c59-9a30-196484a35695 vault && mount /dev/mapper/vault /mnt/vault'` |

- 解锁密码 = 全部数据的钥匙，丢失无法找回，务必离线备份。
- **不要**用 udisks / GNOME Disks 解锁（会挂到动态路径，破坏备份脚本假设）。

---

## 五、Vaultwarden（密码管理器）

| 操作 | 命令/地址 |
|------|-----------|
| 访问 | `https://localhost:8080`（必须 https） |
| 管理后台 | `https://localhost:8080/admin` |
| 重启容器 | `sudo systemctl restart vaultwarden.service` |
| 手动备份一次 | `sudo systemctl start vaultwarden-backup` |
| 数据库文件 | `/var/lib/vaultwarden/db.sqlite3` |
| 本地备份目录 | `/var/lib/vaultwarden/backups/`（保留 7 天） |

备份两层：本地(7d) + 加密盘 `/mnt/vault/vaultwarden/backups/`（只增不删，vault 解锁时才归档）。

---

## 六、sops 机密（secrets/secrets.yaml）

| 操作 | 命令 |
|------|------|
| 编辑机密（明文输入，自动加密） | `sops secrets/secrets.yaml` |
| 改用户密码 | `openssl passwd -6` 生成 hash → sops 更新 `password_hash` → rebuild |
| 检查 Hermes API key 是否解密 | `cat $(readlink -f /run/secrets/hermes-env)` |

- 信任根 `/etc/sops/age/keys.txt` + 用户级 `~/.config/sops/age/keys.txt`，绝不可提交 git，用备份脚本定期备份。

---

## 七、代理

**daed（主用）**
- 面板：`http://127.0.0.1:2023`（初始密码看 `systemctl status daed` 日志）
- 重启：`systemctl restart daed`
- 规则库检查：`ls -l /etc/daed/`（软链应指向 v2ray-rules-dat）

**mihomo（备用）**——配置在 `~/.config/mihomo/config.yaml`（含订阅 token）
- 重启：`systemctl restart mihomo`
- 只刷订阅：`curl -X PUT "http://127.0.0.1:9090/providers/proxies/mysub"`

---

## 八、Hermes

| 操作 | 命令 |
|------|------|
| CLI | `hermes "你好"` |
| 临时切换模型 | `hermes --model deepseek-v4-pro` |
| 服务状态 | `systemctl status hermes-agent` |
| 日志 | `journalctl -u hermes-agent -f` |

---

## 九、备份与重装

| 操作 | 命令 |
|------|------|
| 备份信任根/凭据 | `sudo bash scripts/backup-credentials.sh`（备份到 `/mnt/vault/credentials-backup`，保留 5 份） |
| 备份到指定目录 | `sudo bash scripts/backup-credentials.sh /media/usb/backup` |
| 演练（不写文件） | `sudo DRY_RUN=1 bash scripts/backup-credentials.sh` |
| disko 一键分区（保留 DATATB/加密盘） | `nix run github:nix-community/disko -- --mode format,mount hosts/legion/disko-fs.nix` |
| disko 全新空盘 | `nix run github:nix-community/disko -- --mode create,format,mount hosts/legion/disko-fs.nix` |

完整重装步骤见 README「十一、重装流程」。

---

## 十、输入法 / 桌面 / 杂项

| 操作 | 命令/按键 |
|------|-----------|
| 截图 | `Print`（区域）/ `Alt+Print`（窗口）/ `Ctrl+Print`（全屏），存 `~/Pictures/Screenshots/` |
| Rime 雾凇未出现 | `fcitx5-remote -r`（触发部署） |
| Thunar 配置不生效 | `killall Thunar`（重启后生效） |
| 启动器 / 终端 / 浏览器 | `super+d` walker / `super+return` alacritty / `super+b` chrome |

---

## 十一、开发环境

> 原则：**全局只放工具链，项目依赖全部项目隔离**。Python 用 uv，Node 用 pnpm，环境用项目 `flake.nix + devShell`，direnv 自动进入。

**全局工具链**（`home/programs/dev.nix`）：`uv`、`python3`（裸）、`nodejs_22`、`pnpm`、`just`、`gh`、`yq`。不装全局 python 包 / node 包。

**Python（uv）**：
```bash
cd 项目目录          # .envrc 已 use flake，自动进入 devShell
uv add pandas akshare PySide6   # 版本/venv/lock 全自动
uv run python app.py
uv add --dev ruff pytest        # 开发工具跟着项目走
```
`python3` 只作兜底；不要 `pip install` / conda / poetry。

**Node（pnpm）**：
```bash
cd 项目目录
pnpm install
pnpm add -D vite typescript    # 依赖装项目本地 node_modules
pnpm dev
```
不要 `npm install -g`；node 版本由 Nix 提供，pnpm 版本可用 `packageManager` + corepack 固定。

**脚手架模板**（`nix flake init -t` 一键生成项目）：
```bash
nix flake init -t ~/nixos-DMS#python           # Python 通用
nix flake init -t ~/nixos-DMS#python-pyside6   # Python + PySide6/QML（股票终端等）
nix flake init -t ~/nixos-DMS#python-ai        # Python AI/Data
nix flake init -t ~/nixos-DMS#node             # Node.js
# push 到 GitHub 后也可：-t github:lilei0918/nixos-DMS#<name>
```

**系统级依赖**：编译 C 扩展 / Qt 运行时缺 `.so` 时，往项目 devShell 的 `packages` 或全局 `system/nix-ld.nix` 的 `libraries` 补（nix-ld 已全局配置）。

---

## 十二、排障速查

| 现象 | 处理 |
|------|------|
| `vault-close` 报 target is busy | 有程序占用 `/mnt/vault`，`lsof +D /mnt/vault` 找进程，关闭或 `cd` 离开后重试 |
| `hermes: command not found` | 检查 `addToSystemPackages = true` 且已重建 |
| 输入法不出雾凇 | `fcitx5-remote -r`，再等 5-10 秒 |
| Vaultwarden 打不开/证书错 | 用 `https://localhost:8080`；`systemctl restart vaultwarden.service` |
| daed 报 `code xxx not found` | 确认 `/etc/daed/geosite.dat` 软链，`systemctl restart daed` |
| 构建失败（空间不足） | `sudo nix-collect-garbage -d` |
| 模块报 input 不存在 | 先在 `flake.nix` 添加对应 input |
| 非 Nix 二进制缺库 | 往 `system/nix-ld.nix` 的 `libraries` 补库后 rebuild |
