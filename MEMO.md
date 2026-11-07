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
| 清理 Immich 重复照片（按需） | `sudo systemctl start immich-deduper`（用完 `stop`） |
| 重装系统（本机） | 见本文件「十五、重装 NixOS」 |

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
systemctl is-active vaultwarden.service greetd
```

**⚠️ 本仓库特有的注意**：
- `niri` 使用 nixpkgs 自带 `pkgs.niri`（2026-08-30 改，不再用 niri-flake），配置为手写 KDL（`home/niri/conf/*.kdl`），随 nixpkgs unstable 滚动更新
- 所有 flake input 均 follows 统一 nixpkgs，`nix flake update` 可整体升级
- **ElyOffice（`elyoffice` input）跟随每周升级**：input 指向 `github:ELY-Open-Source/ElyOffice` 的 `main`，`nix flake update` 会把 `flake.lock` 里的 rev 推到上游最新（上游发版后 `nix/release.json` 指向新版本 AppImage，rev 变了就等于应用升级）。⚠️ 有新版本时那次 `nh os test` 会额外下载约 960 MB AppImage（doc/show/table 各约 220 MB），构建时间明显变长，属正常现象；确认版本：`nix flake metadata | grep -A1 elyoffice`
- 大升级后建议重启，确认新 generation 能被引导（NixOS GRUB 主引导，GRUB 菜单里可选旧 generation 回滚）

**坏了的回滚**：
- 启动时在 GRUB 菜单选旧 generation；或 `rollback`

**常见升级踩坑**：
| 现象 | 处理 |
|------|------|
| niri 配置解析失败 | 用 `niri validate` 校验 `~/.config/niri/config.kdl`；niri 随 nixpkgs 升级，KDL 语法若有破坏性变更需同步改 `home/niri/conf/` |
| ElyOffice 构建报 404 / hash mismatch | 上游 `main` 抢先指向了尚未上传的 AppImage，等上游发版完成后重跑 `nix flake update elyoffice`；急用先回退锁文件：`git checkout HEAD -- flake.lock` 再 `nh os switch .#legion` |
| 新 generation 无法引导 | GRUB 选旧 generation 回滚，修复后再切 |

---

## 四、加密盘 /mnt/vault（ZHITAI 盘 20G LUKS 分区）

| 操作 | 命令 |
|------|------|
| 解锁 + 挂载 | `sudo vault-open` |
| 卸载 + 锁 | `sudo vault-close` |
| 查看状态 | `cryptsetup status vault`、`sudo cryptsetup luksUUID /dev/disk/by-uuid/86c742fc-8de5-4c59-9a30-196484a35695` |
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

备份三层：本地(7d) + DATATB 镜像 `/run/media/lilei/DATATB/vaultwarden-backup/`（随 7 天滚动）+ 加密盘 `/mnt/vault/vaultwarden/backups/`（只增不删，vault 解锁时才归档）。

---

## 六、sops 机密（secrets/secrets.yaml）

| 操作 | 命令 |
|------|------|
| 编辑机密（明文输入，自动加密） | `sops secrets/secrets.yaml` |
| 改用户密码 | `openssl passwd -6` 生成 hash → sops 更新 `password_hash` → rebuild |

- 信任根 `/etc/sops/age/keys.txt` + 用户级 `~/.config/sops/age/keys.txt`，绝不可提交 git，用备份脚本定期备份。

---

## 七、代理

**clash-verge（主用）**——Clash Verge Rev（nixpkgs `programs.clash-verge`）
- 打开 GUI：`super+d` / 应用菜单搜索 clash-verge
- 首次：订阅 → 新建 → 粘贴订阅 URL → 更新，选中一个 profile
- 开代理：打开「系统代理」或 Tun 模式
- ⚠️ 单实例：GUI 设置里开启「服务模式」+「Tun 模式」，复用 systemd 常驻的 `clash-verge-service` 核心
- 服务状态：`systemctl status clash-verge-service`

**mihomo（备用）**——配置在 `~/.config/mihomo/config.yaml`（含订阅 token）
- 重启：`systemctl restart mihomo`
- 只刷订阅：`curl -X PUT "http://127.0.0.1:9090/providers/proxies/mysub"`

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
| 输入法不出雾凇 | `fcitx5-remote -r`，再等 5-10 秒 |
| Vaultwarden 打不开/证书错 | 用 `https://localhost:8080`；`systemctl restart vaultwarden.service` |
| 构建失败（空间不足） | `sudo nix-collect-garbage -d` |
| 模块报 input 不存在 | 先在 `flake.nix` 添加对应 input |
| 非 Nix 二进制缺库 | 往 `system/nix-ld.nix` 的 `libraries` 补库后 rebuild |

---

## 十三、Immich 重复照片清理（immich-deduper，按需启动）

> 模块：`system/immich-deduper.nix`；**不常驻、不开机自启**，需要时才起。
> 删除只是把 `asset.status` 改成 `trashed` → 进 Immich 回收站，可恢复。

```bash
# 1) 启动（首次会拉约 2 GB 镜像；后续秒起）
sudo systemctl start immich-deduper

# 2) 打开 UI
xdg-open http://127.0.0.1:8086     # 只有本机能访问

# 3) 看日志 / 状态
sudo systemctl status immich-deduper
sudo journalctl -u immich-deduper -f

# 4) 用完停止（容器与 podman 网络一起清理，数据保留）
sudo systemctl stop immich-deduper
```

**基本流程**（UI 内）：
1. `Fetch` 页 → `Get Assets`（选用户；本库约 4 万张）
2. `Vector` 页 → 生成向量（CPU 版，**最耗时，可能数小时**；可先按 `NameFilter`/`Path Filter` 缩小范围，如排除 `.dng,.png`）
3. `Similar` 页 → `Find Similar`（阈值从 0.97+ 开始抓完全重复，再逐级降到 0.90/0.80）
4. 逐组人工确认后删除；`Kept` 标记会保护后续组里的同张照片
5. 之后到 Immich 的「回收站」确认/彻底删除

**数据与清理**：
- 数据在 `/var/lib/immich-deduper/{data,qdrant}`；`data/` 属主 `immich`、组 `users`，`lilei` 可读日志（`.../data/logs/deduper.log`）
- 想彻底重来：`sudo rm -rf /var/lib/immich-deduper`（下次启动自动重建目录）
- 查/清理镜像：`sudo podman images | grep -E 'immich-deduper|qdrant'`、`sudo podman rmi <id>`

**说明（为什么这样配）**：
- 用 **rootful** podman：`/srv/immich` 是 `0700 immich:immich`，rootless 读不到缩略图
- 容器以 `immich` 的 uid 运行 → PostgreSQL `local all all peer` 认作 role `immich`，**不用给角色设密码、不开 5432**
- 媒体目录同路径只读挂载（`/srv/immich:/srv/immich:ro`）：podman 不生成 `/.dockerenv`，Deduper 判 `IS_DOCKER=false`，不会把路径重映射成 `/immich`
- UI 只发布到 `127.0.0.1:8086`，不经过防火墙、不暴露局域网
- 镜像固定在 `razgrizhsu/immich-deduper:0.3.5`（CPU；AMD 核显不支持，上游只有 NVIDIA CUDA 变体）；升级改模块里的 `image` 标签后 `rebuild`
- 视频/大文件的元数据合并（Metadata Merge, BETA）未启用：媒体只读挂载，写 XMP 会失败

---

## 十四、Immich Power Tools（批量整理，按需启动）

> 模块：`system/immich-power-tools.nix`；**不常驻、不开机自启**。
> 直连 Immich 数据库读取 + 走 Immich API 写入，**不挂载媒体目录**。

```bash
# 1) 首次：先去 Immich 网页建 API 密钥
#    账户设置 → API 密钥 → 新建 → 勾选【全部权限】→ 复制
#    注意：密钥只显示一次

# 2) 第一次启动（会生成 env 模板，并因缺少 key 而退出）
sudo systemctl start immich-power-tools

# 3) 填入密钥（root 0600）
sudoedit /var/lib/immich-power-tools/power-tools.env
#   IMMICH_API_KEY=粘贴你的key

# 4) 再启动
sudo systemctl start immich-power-tools
xdg-open http://127.0.0.1:8001        # 用 Immich 的邮箱/密码登录

# 5) 日常
sudo systemctl status immich-power-tools
sudo journalctl -u immich-power-tools -f
sudo systemctl stop immich-power-tools
```

**功能对应**：人物批量编辑/相似度合并、缺失位置补全、潜在相册、统计（EXIF/时间分布）、
Smart Search（自然语言）、批量日期偏移。

**可选：Smart Search 的自然语言解析**（需要 OpenAI 兼容接口；只发送查询文本，不发照片数据）

```bash
sudoedit /var/lib/immich-power-tools/power-tools.env
#   AI_API_KEY=...
#   AI_BASE_URL=https://api.openai.com/v1     # 或 http://127.0.0.1:11434/v1（Ollama）
#   AI_MODEL=gpt-4o-mini
```

**数据与重置**：
- `/var/lib/immich-power-tools/data/app.db`（它自己的 SQLite，删掉即重置界面状态）
- `/var/lib/immich-power-tools/cache`（Next.js 图片缓存，可随意删）
- env 文件：`/var/lib/immich-power-tools/power-tools.env`（含 API key 与 `JWT_SECRET`，**不要提交到仓库**）

**说明（为什么这样配）**：
- 数据库走 `DB_HOST=/run/postgresql` + `DB_USERNAME=immich`，容器以 `immich` uid 运行 →
  PostgreSQL peer 认证通过；**不需要 DB 密码、不暴露 5432**（上游强制 DB_PASSWORD 非空，填占位值，peer 下被忽略）
- 端口固定 `127.0.0.1:8001`（`HOSTNAME` + `PORT` 环境变量），不进防火墙、不暴露局域网
- 想开机常驻：把 `system/immich-power-tools.nix` 里 `wantedBy = [];` 改成 `wantedBy = ["multi-user.target"];`

---

## 十五、重装 NixOS（本机 reinstall 手册）

> **铁律：全程只用 `by-id` / UUID / 文件系统标签识别设备，不写 `nvmeXnY`**（本机已发生过编号互换）。
> 目标盘是 **ZHITAI 的 p2（NIXOS 根分区）**；`p1` DATATB、`p3` vault、以及另一块 SK Hynix 整盘都**不能动**。

### 0. 两张盘（2026-11-07 实测）

| 盘（by-id） | 分区表 | 内容 |
|---|---|---|
| `nvme-SKHynix_HFS512GDE9X084N_CJA5N775913905S66`（512G） | GPT | p1 Windows ESP `785A-7651` / p2 MSR / p3 Win11 `68D4EDC8D4ED9918` / p4~p5 WinRE / **p6 NixOS ESP `AC09-EF5B`（`/boot/efi`）** / **p7 Immich 库 `IMMICH` `5c0e846a-…`（`/srv/immich`）** |
| `nvme-ZHITAI_TiPlus7100_1TB_ZTA71T0AB24182L6AD`（1T） | **MBR** | **p1 DATATB `FAC6848EC6844D37`** / **p2 NIXOS root `6c9764ff-…`** / **p3 vault（LUKS）`86c742fc-…`**（物理顺序 p1→p3→p2） |

### 1. 重装前（旧系统里）必须备份

```bash
sudo vault-open                                  # 加密盘先解锁
sudo bash scripts/backup-credentials.sh          # 信任根/凭据 → /mnt/vault/credentials-backup/latest
                                                 #（含 /etc/sops/age/keys.txt、~/.config/sops/age/keys.txt、
                                                 #  ~/.ssh/、opencode auth、mihomo 配置）

sudo systemctl start immich-backup               # 仅数据库 dump：/srv/immich/backups/db/ + DATATB 镜像
sudo systemctl start vaultwarden-backup          # Vaultwarden → /run/media/lilei/DATATB/vaultwarden-backup/

# 家目录（@home 会被清空）→ 备份到 DATATB（NTFS，p1，不会被格式化）
rsync -a --info=progress2 /home/lilei/ /run/media/lilei/DATATB/home-backup/

# 顺手记下当前磁盘状态（对照用）
lsblk -o NAME,SIZE,FSTYPE,LABEL,UUID,PTTYPE | tee /run/media/lilei/DATATB/lsblk-before-reinstall.txt
```

**会被清掉**：`/` `/home` `/nix` `/var/log`（即 ZHITAI p2 上的 `@ @home @nix @log`），包括 Immich 的数据库 `/var/lib/immich`、Vaultwarden 的 `/var/lib/vaultwarden`。
**不会被动**：DATATB（p1）、vault（p3）、Immich 媒体库（Hynix p7）、Windows（Hynix p1~p5）。

### 2. 启动安装环境

- 用 NixOS 官方 ISO 写 U 盘；BIOS 关 Secure Boot，从 U 盘启动
- 联网：`nmtui`（有线/无线）或 `iwctl`
- **确认两块盘都在**（编号不重要，看 by-id）：

```bash
ls -l /dev/disk/by-id | grep -E 'ZHITAI|SKHynix'
lsblk -o NAME,SIZE,FSTYPE,LABEL,UUID,PTTYPE
```

### 3. 场景 A（推荐）：只重装根分区

```bash
# 取仓库（联网）
git clone https://github.com/lilei0918/nixos-DMS.git
cd nixos-DMS

# 只格式化并挂载 ZHITAI p2（disko 里只有 NIXOS 分区带 content，p1/p3 无 content 不会被格式化）
nix run github:nix-community/disko -- --mode format,mount hosts/legion/disko-fs.nix
#   ⚠️ 看它打印的命令：mkfs/mount 目标必须是 ...-part2。
#      若出现 part1 或 part3，立刻 Ctrl-C —— 说明 disko 文件被改错了。

# 挂 NixOS ESP（Hynix p6）
mkdir -p /mnt/boot/efi
mount /dev/disk/by-uuid/AC09-EF5B /mnt/boot/efi
```

### 4. 更新根分区 UUID（不做会起不来）

重新 mkfs 后 btrfs UUID 会变，而 `hardware-configuration.nix` 写死了旧的 `6c9764ff-…`：

```bash
lsblk -no UUID /dev/disk/by-id/nvme-ZHITAI_TiPlus7100_1TB_ZTA71T0AB24182L6AD-part2
#   假设输出 NEWUUID
sed -i 's/6c9764ff-c293-4be8-801c-982bdb6ed30a/NEWUUID/g' hosts/legion/hardware-configuration.nix
grep -c NEWUUID hosts/legion/hardware-configuration.nix      # 应为 4（/ /home /nix /var/log）
```

> 想一劳永逸：把这 4 处 `device` 改成 `/dev/disk/by-label/NIXOS`，并在 `hosts/legion/disko-fs.nix`
> 的 btrfs `extraArgs` 里加 `"-L" "NIXOS"`（目前 disko 没写标签，格式化后 label 为空）。

### 5. 放 age 信任根 + 让仓库就位

```bash
# 5.1 sops 解密钥匙（激活阶段要用它解出用户密码 hash 等）
mkdir -p /mnt/etc/sops/age
cp /mnt/vault/credentials-backup/latest/etc-sops-age-keys.txt /mnt/etc/sops/age/keys.txt
chmod 600 /mnt/etc/sops/age/keys.txt
#   若 vault 尚未挂载：
#   cryptsetup open UUID=86c742fc-8de5-4c59-9a30-196484a35695 vault
#   mount /dev/mapper/vault /mnt/vault

# 5.2 仓库放进目标系统的 home（此时 /mnt/home 就是 @home 子卷）
mkdir -p /mnt/home/lilei
mv nixos-DMS /mnt/home/lilei/nixos-DMS
chown -R 1000:100 /mnt/home/lilei
```

### 6. 安装

```bash
nixos-install --root /mnt --flake /mnt/home/lilei/nixos-DMS#legion --no-root-password   --option substituters "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store https://cache.nixos.org"

reboot    # 拔掉 U 盘
```

- `--no-root-password`：root/lilei 的密码 hash 由 sops 管理
- 首次构建 30–60 分钟属正常
- 只有**已跟踪文件**的修改会被 flake 看到；新建文件记得先 `git add`

### 7. 场景 B：换新盘 / 重建整盘分区表（会毁数据）

```bash
nix run github:nix-community/disko -- --mode create,format,mount hosts/legion/disko-fs.nix
```

⚠️ 清空 ZHITAI 整盘（**DATATB + vault + root**）。之后仍需第 4~6 步，另外：

- ESP 仍在 Hynix p6；**若换的就是 Hynix 盘**，得先建 ESP，并改 `system/boot.nix` 的 `785A-7651`
- vault 要重新 `luksFormat`（UUID 变了 → `system/vault/vault.nix` 也要改）
- DATATB 要重新 `mkfs.ntfs -L DATATB` 并从备份恢复
- 新盘 by-id 不同时，必须先改 `hosts/legion/disko-fs.nix` 的 `device`

### 8. 首启后恢复数据

```bash
# 8.1 家目录
sudo rsync -a /run/media/lilei/DATATB/home-backup/ /home/lilei/
sudo chown -R lilei:users /home/lilei

# 8.2 Immich 数据库（相册/人物/时间线；媒体原图在 Hynix p7，未动）
#     备份只含数据库；最近的 dump 在 /srv/immich/backups/db/（若 /srv/immich 被重建则用 DATATB 镜像：
#     /run/media/lilei/DATATB/immich-backup/db/）
ls /srv/immich/backups/db/ | tail -3            # 找最新 dump
sudo systemctl stop immich-server immich-machine-learning
sudo -u postgres psql -c 'DROP DATABASE IF EXISTS immich;'
sudo -u postgres psql -c 'DROP ROLE IF EXISTS immich;'
zcat /srv/immich/backups/db/immich-db-<最新>.sql.gz | sudo -u postgres psql
sudo systemctl start immich-server

# 8.3 Vaultwarden（SQLite）
ls /run/media/lilei/DATATB/vaultwarden-backup/ | tail -3
sudo systemctl stop vaultwarden
sudo install -m 600 /run/media/lilei/DATATB/vaultwarden-backup/backup-<最新>.db /var/lib/vaultwarden/db.sqlite3
sudo systemctl start vaultwarden
```

### 9. 验收清单

| 检查 | 命令/预期 |
|---|---|
| 三块数据都在 | `lsblk -o NAME,FSTYPE,LABEL,UUID` → DATATB / IMMICH / NIXOS |
| 加密盘 | `sudo vault-open && ls /mnt/vault` |
| Immich | `systemctl status immich-server`；浏览器 `http://<局域网IP>:2283` 照片数正常 |
| Vaultwarden | `systemctl status vaultwarden`；`https://localhost:8080` |
| 双系统菜单 | GRUB 里有 `Windows 11`，能进 |
| 桌面 | niri 登录、输入法（`fcitx5-remote -r`）、字体、walker |
| 仓库状态 | `git -C ~/nixos-DMS status`；第 4 步的 UUID 改动要提交 |
| 备份链 | `sudo systemctl start immich-backup vaultwarden-backup` 各跑一次成功 |
| 后续切换 | `nh os switch .#legion` 正常 |

### 10. 常见坑

| 现象 | 处理 |
|---|---|
| 装完起不来，`dependency failed`/找不到 UUID | 第 4 步没做：`hardware-configuration.nix` 还是旧 UUID |
| disko 警告 legacy table deprecated | 正常（MBR 只能用 legacy table） |
| 安装时下载很慢 | 第 6 步加 `--option substituters` 国内镜像 |
| GRUB 里没有 Windows | 确认 Hynix p1 仍是 `785A-7651`；`efibootmgr -v` 看启动项 |
| Immich 起来但 0 张照片 | `/srv/immich` 没挂上（`findmnt /srv/immich`）或数据库没恢复 |
| 家目录属主变成 root | `sudo chown -R lilei:users /home/lilei` |
| 忘记提前取 age key | 别重启进新系统：回到旧系统/从 `/mnt/vault` 或备份介质取，放到 `/mnt/etc/sops/age/keys.txt` 后再 `nixos-install` |
| 误把 p1/p3 格式化了 | 立刻停止操作；DATATB 试图 `ntfsfix`/数据恢复，vault 无 LUKS header 备份则不可恢复 —— 这正是「只用 by-id、开跑前核对 `partN`」的原因 |
