# nixos-DMS — NixOS 配置参考手册（README）

本仓库是 Lei 的 NixOS 配置（flake 化），目标主机 Lenovo Legion R7000P 2021。本文档既是仓库 README，也是面向 **AI 助手（Hermes / opencode 等）与本人备查**的完整参考手册：覆盖硬件、目录结构、各模块详解、维护流程与排障。

**技术栈**：NixOS（nixos-unstable）+ niri（滚动式 Wayland compositor）+ DankMaterialShell + greetd/tuigreet + Home Manager + sops-nix（age 加密）。主机配置名 `legion`，主机名 `nixos`。

改动配置的流程不变：
cd nixos-DMS
alejandra .
nix flake check 
git add -A && git commit -m "before switch"
nh os switch .#legion


> **目标**：让 AI 助手（Hermes 等）理解这套 NixOS 配置的完整结构、硬件背景和日常维护流程，以便提供精准的操作建议。
> **本文档基于仓库实际文件内容整理（2026-08-16 通读核实），与配置仓库同步维护。**
> 动态值（generation、版本号等）以实际命令输出为准。

---

## 一、硬件与系统概览

- **机型**：Lenovo Legion R7000P 2021（AMD 平台）
- **CPU**：AMD Ryzen 5 5600H（12 线程，基础频率 3.3GHz，最高 4.28 GHz）
- **GPU**：
  - 集成显卡：AMD Radeon Vega Series（当前驱动 `amdgpu`）
  - 独立显卡：NVIDIA（当前通过 `nvidia-block.nix` 屏蔽 Nouveau 和 nvidia 内核模块，未启用；`system/nvidia/nvidia.nix` 保留完整独显配置供日后启用）
- **内存**：32GB
- **存储**（⚠️ NVMe 设备名 `nvme0n1`/`nvme1n1` 会随 BIOS 枚举顺序变化，**一切以 UUID 为准**，详见下方分区详表）：
  - **nvme0n1 — SKHynix 512GB**（型号 SKHynix_HFS512GDE9X084N）：Windows 11 + Arch Linux 双系统盘（Arch 的 btrfs 分区 `myArch` 是 Vaultwarden 备份的自动镜像目标）
  - **nvme1n1 — ZHITAI 1TB**（型号 ZHITAI TiPlus7100 1TB）：NixOS 主盘（Btrfs 根分区）+ NTFS 数据盘 DATATB + **20G LUKS 加密盘**，用作密码库/个人文件

### 存储与分区详表（2026-08-04 实测，2026-08-16 复验未变）

> 数据核实于 2026-08-04（`lsblk` / `blkid`）。⚠️ 设备名（`nvme0n1`/`nvme1n1`、`p1`~`p7`）在不同启动可能互换，**配置与脚本一律用 UUID**，故本表 UUID 才是权威标识。

#### 盘 A：`nvme0n1` — SKHynix 512GB（GPT，Windows 11 + Arch Linux）

| 分区 | 大小 | 文件系统 | 标签 | 用途 | UUID（FS） | PARTUUID |
|------|------|---------|------|------|-----------|----------|
| `nvme0n1p1` | 100 MB | vfat | — | Windows EFI 分区 | `785A-7651` | `2997a151-0dad-410f-9f57-50fef583b05d` |
| `nvme0n1p2` | 16 MB | — | — | Microsoft Reserved (MSR) | — | `46a4cccd-a73b-4105-a662-a018a613c2d9` |
| `nvme0n1p3` | 148.5 GB | ntfs | Win11 | Windows 11 系统盘 (C:) | `68D4EDC8D4ED9918` | `e68b0315-6182-4c7f-b465-ae6b74480f0e` |
| `nvme0n1p4` | 860 MB | ntfs | — | Windows 恢复分区 (WinRE) | `B01E9F761E9F33F6` | `c9a86558-9295-4e88-8553-3061acf3c73e` |
| `nvme0n1p5` | 571 MB | ntfs | — | Windows 恢复分区 (WinRE) | `6016A3AC16A381A0` | `29f912b6-a781-4cba-8913-41767db0879e` |
| `nvme0n1p6` | 1 GB | vfat | — | **Arch/NixOS 共用 EFI**（systemd-boot，挂载 `/boot/efi`） | `9B06-514F` | `ab0a2471-a034-417b-9c18-8867261314b6` |
| `nvme0n1p7` | 325.9 GB | btrfs | myArch | **Arch Linux 根分区** | `9dccd22a-c64e-494b-ab1a-e226b843516e` | `5db57926-a703-4680-ae4a-9da3465bd86e` |

- nvme0n1p7 的 Btrfs 顶层（`subvol=/`）下子卷：`@`、`@cache`、`@home`、`@log`、`@snapshots`、`@tmp`（Arch 侧）
- Vaultwarden 每日备份的 Arch 盘镜像目标即此分区（`subvol=/` 顶层，`@home/anan/Documents/vaultwarden-backup`），与配置文件 `vaultwarden-backup.nix` 中的 UUID `9dccd22a-...` 对应

#### 盘 B：`nvme1n1` — ZHITAI TiPlus7100 1TB（NixOS 主盘）

| 分区 | 大小 | 文件系统 | 标签 | 用途 | UUID（FS） | PARTUUID |
|------|------|---------|------|------|-----------|----------|
| `nvme1n1p1` | 783.9 GB | ntfs | DATATB | 数据盘（挂载 `/run/media/lilei/DATATB`） | `FAC6848EC6844D37` | `ebf47cf2-01` |
| `nvme1n1p2` | 150 GB | btrfs | NIXOS | **NixOS 根分区**（挂载 `/`、`/home`、`/nix`、`/var/log` 等子卷） | `6c9764ff-c293-4be8-801c-982bdb6ed30a` | `ebf47cf2-02` |
| `nvme1n1p3` | 20 GB | LUKS2 | — | **加密数据盘**（密码库/个人文件，挂载 `/mnt/vault`） | `86c742fc-8de5-4c59-9a30-196484a35695` | `ebf47cf2-03` |

- nvme1n1p2 的 Btrfs 子卷：`@`→`/`、`@home`→`/home`、`@nix`→`/nix`、`@log`→`/var/log`（见 `hardware-configuration.nix`）
- `nvme1n1p3` 即 LUKS 加密盘，对应 `vault.nix` 中的 LUKS UUID `86c742fc-...`；解锁后为 ext4，挂载 `/mnt/vault`
- **DATATB 自动挂载**：已在 `hosts/legion/configuration.nix` 的 `fileSystems."/run/media/lilei/DATATB"` 中配置（`ntfs3` + `x-systemd.automount`，`nofail`，uid=1000/gid=100/umask=022），挂载点与 udisks2 路径保持一致

- **多系统引导**：Arch Linux 的 GRUB 作为主引导，管理三个系统（Arch、Win11、NixOS）。NixOS 自身使用 **systemd-boot** 作为次引导，用于选择 NixOS 的 generations。
- **主机名**：`nixos`（`system/network.nix` 中设置；flake 配置名才是 `legion`）
- **NixOS 用户**：仅 **`lilei`**（普通用户，加入 `wheel`、`networkmanager`、`video`、`input`、`hermes` 组）。
- **配置仓库**：`git@github.com:lilei0918/nixos-DMS.git`（本地路径 `/home/lilei/nixos-DMS`），已备份。

---

## 二、当前系统状态（快照）

> 数据核实于 2026-08-16，部分动态值会变化。以实际命令输出为准。

- **NixOS 版本**：26.11.20260807.f13ff45 (Zokor) —— 实际使用 nixpkgs unstable（commit f13ff45），`system.stateVersion` 设为 `25.05`
- **内核**：Linux 7.1.7（来自 `linuxPackages_latest`）
- **显示管理器**：greetd + **tuigreet**（Wayland 会话，`--cmd niri-session`）
- **窗口管理器**：niri stable v25.08（滚动式 Wayland compositor，commit `01be0e65f4eb...`，来自 niri-flake 的 `niri-stable`，见 home.nix 的 package 覆盖）
- **默认终端**：alacritty 0.17.0（`super+return`）；ghostty 为次选（`super+shift+return`）
- **当前 Shell**：fish 4.8.1（终端常用）；默认登录 shell 为 zsh 5.9.2，可自由切换
- **系统 Generation**：103（2026-08-16 实测 `/nix/var/nix/profiles/system-103-link`；仓库工作区可能已有未提交的「before switch」改动，以新 generation 为准）
- **系统已安装天数**：19 天（从本次安装算起，`stat -c %W /` 的 birth time）
- **Hermes 服务状态**：`hermes-agent` 运行中（active）
- **其他服务**：`greetd` / `daed` / `vaultwarden.service` 均 active

---

## 三、目录结构与职责

```text
nixos-DMS/
├── flake.nix                # 总入口：inputs / outputs（含 eval 测试、pre-commit 钩子、devShell）
├── flake.lock               # 锁定所有 inputs 版本
├── README.md                # 本文档（完整参考手册：仓库简介 + 全部配置详解）
├── MEMO.md                  # 命令速查备忘录（日常备查）
├── AGENTS.md                # AI agent 行为规则（安全边界、机密处理、工具默认值）
├── agents/
│   ├── README.md            # 说明本目录（规则/权限配套）
│   └── permissions.md       # 权限策略（敏感文件 deny、命令 allow/ask）
├── vars/
│   └── default.nix          # 集中变量（username/homeDirectory/repoDir/flakeName），经 myvars 注入所有模块
├── tests/                   # flake 求值测试（expr.nix vs expected.nix，`nix flake check` 自动跑）
├── secrets/
│   └── secrets.yaml         # 加密的机密文件（sops：deepseek_api_key / vaultwarden_admin_token / password_hash / vaultwarden_tls_*）
├── hosts/
│   └── legion/              # 主机专属配置（flake 配置名 legion）
│       ├── configuration.nix   # NixOS 系统配置入口（导入所有模块；DATATB 自动挂载）
│       ├── hardware-configuration.nix  # 硬件自动生成（勿手动修改）
│       ├── disko-fs.nix        # disko 声明式分区（重装用，只动 nvme1n1p2，保留 DATATB/加密盘）
│       ├── home.nix            # Home Manager 入口（niri-stable 覆盖）
│       └── packages.nix        # 用户级软件包列表
├── scripts/                # 运维辅助脚本
│   ├── backup-credentials.sh # 信任根/凭据备份（sops age key / ssh / opencode auth）
│   └── README.md           # 脚本用法与故障排查
├── system/                  # 系统级配置（影响所有用户）
│   ├── nix.nix              # Nix 自身设置（flakes、镜像源、GC 3d、NUR overlay）
│   ├── cleanup.nix          # journal 日志上限 50M + 用户缓存 tmpfiles 3d 清理
│   ├── boot.nix             # 启动引导（systemd-boot）
│   ├── hardware.nix         # 硬件：GPU 图形、蓝牙、fstrim、btrfs scrub
│   ├── network.nix          # 网络（NetworkManager、NTP）——防火墙配置已下放到 proxy/*.nix
│   ├── services.nix         # 系统服务（DMS、PipeWire、Hermes Agent）
│   ├── secrets.nix          # sops 机密声明
│   ├── fonts.nix            # 字体（思源黑体/宋体、Inter、JetBrainsMono NF + fontconfig 映射）
│   ├── input.nix            # 输入法（Fcitx5/Rime）
│   ├── xdg.nix              # XDG 桌面门户（gtk 后端）
│   ├── greetd.nix           # 登录管理器（greetd + tuigreet）
│   ├── nix-ld.nix           # nix-ld 动态链接器（非 Nix 二进制运行所需系统库 + jpeg-8 旧 ABI）
│   ├── packages.nix         # 系统级软件包列表
│   ├── proxy/               # 代理（daed 主用，mihomo 备用）
│   │   ├── daed.nix             # 【启用】daed（dae eBPF 透明代理 + Web 面板）
│   │   └── mihomo.nix           # 【备用】mihomo（TUN 模式，切回方法见文件头注释）
│   ├── nvidia/              # NVIDIA 显卡模块
│   │   ├── nvidia-block.nix     # 【启用】屏蔽 NVIDIA 独显（省电）
│   │   └── nvidia.nix           # 【未启用】完整 NVIDIA 独显配置（prime sync，供日后启用）
│   └── vault/               # 加密数据盘 + Vaultwarden 密码管理器
│       ├── vault.nix            # LUKS 加密盘（vault-open / vault-close，手动解锁）
│       ├── vaultwarden.nix      # 密码管理器（Podman + Quadlet 容器，SQLite，TLS 走 sops）
│       ├── vaultwarden-backup.nix  # 每日在线备份（本地 + Arch 盘 + 加密盘按需）
│       └── certs/               # Vaultwarden 本地 CA 公钥（vaultwarden-ca.crt，私钥走 sops）
├── home/                    # 用户级配置（仅 lilei）
│   ├── niri/                # Niri 窗口管理器配置
│   │   ├── default.nix      # 入口（合并 settings/keybinds/rules/autostart）
│   │   ├── settings.nix     # 核心设置（工作区、布局、输入、输出、环境变量）
│   │   ├── keybinds.nix     # 快捷键（截图用 niri 内置动作）
│   │   ├── rules.nix        # 窗口规则
│   │   └── autostart.nix    # 自动启动程序
│   ├── terminal/            # 终端相关
│   │   ├── alacritty.nix    # 主终端（Monokai Pro 配色、fish）
│   │   ├── ghostty.nix      # 次选终端（Monokai Pro 主题）
│   │   ├── fish.nix         # fish shell（别名、插件）
│   │   ├── zsh.nix          # zsh（oh-my-zsh、别名）
│   │   ├── starship.nix     # prompt
│   │   └── tmux.nix
│   └── programs/            # 用户软件包及配置
│       ├── AI/              # AI 工具（zed.nix / opencode.nix / pi.nix）
│       ├── btop.nix
│       ├── chrome.nix       # Google Chrome（Wayland + VA-API 硬解）
│       ├── dconf.nix        # GNOME dconf 主题设置
│       ├── fastfetch.nix    # 系统信息（logo 用 assets/icons/logo.png，自适应终端宽度）
│       ├── firefox.nix      # Firefox（NUR 扩展、搜索配置）
│       ├── git.nix          # git + delta
│       ├── hermes.nix       # Hermes Desktop
│       ├── rime.nix         # Rime 输入法（rime-ice 方案 + fcitx 环境变量）
│       ├── theme.nix        # GTK/Qt 主题（WhiteSur）
│       ├── thunar.nix       # 文件管理器（xfconf 依赖）
│       ├── vscode/          # VSCodium 配置（vscode.nix）
│       └── walker.nix       # 应用启动器（+ elephant 剪贴板依赖）
└── assets/                  # 静态资源
    └── icons/               # 图标（仅 logo.png，fastfetch 使用）
```

> 生成/忽略文件（不在 git 内）：`niri-colors.generated.kdl`（dms 动态主题生成）、`.pre-commit-config.yaml`（git-hooks.nix 生成）、`result/`、`.direnv/`。`.typos.toml` 是 typos 拼写检查配置（已提交）。
> 本仓库几乎每个子目录都带一份轻量 `README.md`（文件索引 + 要点 + 指回本文档对应章节），AI agent 可直接就地读取。

---

## 四、核心配置文件详解

### 1. `flake.nix`

**作用**：定义所有输入源，输出 NixOS 配置、测试、checks 和 devShell。

**关键内容**：
- `inputs` 包含：
  - `nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"`
  - `home-manager`（follows nixpkgs）
  - `nur`（NUR 仓库）
  - `dms`（DankMaterialShell，`github:AvengeMedia/DankMaterialShell/stable`，follows nixpkgs）
  - `niri`（`github:sodiboo/niri-flake`，**nixpkgs 固定到 `624af66`**，见下）
  - `hermes-agent`（固定 commit `1cdb8ce361e91c79cfbd6bee550ee6c09d290261`，nixpkgs 也固定 `624af66`）
  - `sops-nix`（follows nixpkgs）
  - `pre-commit-hooks`（`github:cachix/git-hooks.nix`，follows nixpkgs，提供 alejandra + typos 钩子）
  - `daeuniverse`（固定 commit `42ece300b6360bab592f13c64ce1987df20475d5`，nixpkgs 固定 `b12141ef`，**不 follows**）
- **nixpkgs pin 说明**：
  - `niri` / `hermes-agent` 的 nixpkgs pin 到 `624af66`（libdisplay-info 0.2.0）。新 nixpkgs 升到 0.3 并删掉 `libdisplay-info_0_2`，niri-flake 仍断言 0.2.0，故 pin 到验证过的旧 commit 避免连带破坏。
  - `daeuniverse` 不 follows、pin 到 `b12141ef`（pnpm 10.x）。跟随最新 nixpkgs（pnpm 11+）会导致 daed 的 `fetchPnpmDeps(fetcherVersion=3)` 构建失败。
- `outputs`：
  - `nixosConfigurations.legion`：`nixosSystem`（system = `x86_64-linux`），`specialArgs = { inherit self inputs myvars; }`（`myvars` 来自 `./vars`），模块：
    - `./hosts/legion/configuration.nix`
    - `home-manager.nixosModules.default`
    - `hermes-agent.nixosModules.default`
    - `sops-nix.nixosModules.sops`
  - `evalTests`：import `./tests`，全部断言通过才为 true（求值失败即抛错）
  - `checks.x86_64-linux`：`evalTestsCheck`（包装 eval 测试）+ `preCommitCheck`（alejandra `--check` + typos），供 `nix flake check` 使用
  - `devShells.x86_64-linux.default`：`nix develop` 进入开发环境（含 alejandra/typos，自动装 git pre-commit 钩子）
  - `formatter.x86_64-linux`：`alejandra`

### 2. `hosts/legion/configuration.nix`

**作用**：主机入口，导入所有系统级模块并配置用户。

**关键内容**：
- `imports` 列表（按分组）：
  - 硬件：`./hardware-configuration.nix`
  - system 模块：`../../system/nix.nix`、`cleanup.nix`、`boot.nix`、`hardware.nix`、`network.nix`、`services.nix`
  - desktop：`fonts.nix`、`input.nix`、`xdg.nix`
  - programs：`../../system/nvidia/nvidia-block.nix`（启用 block 不是 nvidia）、`../../system/proxy/daed.nix`（主用）、`packages.nix`、`nix-ld.nix`
  - vault：`../../system/vault/vaultwarden.nix`、`vaultwarden-backup.nix`、`vault.nix`
  - greeter：`greetd.nix`
  - secrets：`secrets.nix`
- 用户 `lilei`（经 `myvars.username`）：`isNormalUser = true`，`shell = pkgs.zsh`，`extraGroups = [ "wheel" "networkmanager" "video" "input" "hermes" ]`。密码 hash 不落仓库：`hashedPasswordFile = config.sops.secrets.password_hash.path`。
- **DATATB 自动挂载**：`fileSystems."/run/media/lilei/DATATB"` = ntfs3（`/dev/disk/by-label/DATATB`，`uid=1000 gid=100 umask=022 nofail x-systemd.automount`）。
- `environment.localBinInPath = true`：把 `~/.local/bin` 加进 PATH（自定义脚本：futu 等）。
- Home Manager：`useGlobalPkgs = true`、`useUserPackages = true`、`extraSpecialArgs = { inherit inputs myvars; }`、`users.${myvars.username} = import ./home.nix`、备份扩展名 `backup`。
- `programs.dconf.enable = true`；`time.timeZone = "Asia/Shanghai"`、`console.keyMap = "us"`；`programs.zsh.enable = true`；`system.stateVersion = "25.05"`。
- `system.activationScripts.logRebuildTime` 写入 `/var/log/nixos-rebuild-log.json`（记录重建日期和 generation 号）。

### 3. `hosts/legion/hardware-configuration.nix`

**作用**：硬件自动生成（`nixos-generate-config`，勿手动修改）。

**关键内容**：
- 导入 `modulesPath + "/installer/scan/not-detected.nix"`
- `boot.initrd.availableKernelModules`：`nvme`, `xhci_pci`, `ahci`, `usbhid`, `usb_storage`, `sd_mod`
- 文件系统挂载（Btrfs 子卷，UUID `6c9764ff-c293-4be8-801c-982bdb6ed30a`）：
  - `/` → 子卷 `@`，`compress=zstd,noatime,discard=async`
  - `/home` → 子卷 `@home`、`/nix` → 子卷 `@nix`、`/var/log` → 子卷 `@log`
  - `/tmp` → tmpfs（`mode=1777,nosuid,nodev,size=4G`）
  - `/boot/efi` → VFAT，UUID `9B06-514F`，`fmask=0022,dmask=0022`
- `swapDevices = []`（无交换）
- `networking.useDHCP = lib.mkDefault true`
- `nixpkgs.hostPlatform = "x86_64-linux"`
- `hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware`

### 4. `system/nix.nix`

**作用**：Nix 自身配置。

**内容**：
- `nixpkgs.overlays`：加载 NUR（`import inputs.nur { nurpkgs = prev; pkgs = prev; }`）→ 提供 `pkgs.nur`
- 启用 flakes 和 nix-command：`experimental-features = [ "nix-command" "flakes" ]`
- `auto-optimise-store = true`
- `substituters`：Tuna（priority 1）、USTC（priority 2）、cache.nixos.org（priority 20）
- `trusted-public-keys`：cache.nixos.org 的 key
- `nix.gc`：自动，`dates = "daily"`，`options = "--delete-older-than 3d"`（内置 nix-gc.timer 带 Persistent=true，关机错过会在开机补跑）
- `nixpkgs.config.allowUnfree = true`

### 5. `system/cleanup.nix`（新增）

**作用**：系统日志与用户缓存自动清理。

**内容**：
- `services.journald.extraConfig`：`SystemMaxUse=50M`、`SystemKeepFree=1G`（journal 不会涨满 /var/log）
- `systemd.tmpfiles.rules`（由 systemd-tmpfiles-clean.timer 每日执行，只删超龄条目）：
  - `~/.cache/uv`、`~/.cache/pip`、`~/.cache/nix`、`~/.cache/elephant` → 3d
  - 浏览器缓存默认不清（注释中给出 7d 方案）

### 6. `system/boot.nix`

**内容**：
- `boot.loader.grub.enable = false`
- `boot.loader.systemd-boot`：`enable = true`，`configurationLimit = 5`
- `boot.loader.efi.efiSysMountPoint = "/boot/efi"`
- `boot.loader.efi.canTouchEfiVariables = false`
- `boot.tmp.cleanOnBoot = true`
- `boot.kernelPackages = pkgs.linuxPackages_latest`
- `boot.kernelParams = [ "amd_pstate=passive" "nowatchdog" ]`

### 7. `system/hardware.nix`

**内容**：
- `hardware.graphics.enable = true`，`extraPackages = [ libva libvdpau vulkan-loader vulkan-tools vulkan-validation-layers ]`
- `hardware.bluetooth`：`enable = true`，`powerOnBoot = true`
- `hardware.enableRedistributableFirmware = true`
- `services.udev.packages = [ pkgs.rwedid ]`
- `services.fstrim.enable = true`
- `services.btrfs.autoScrub.enable = true`

### 8. `system/network.nix`

**内容**：
- `networking.hostName = "nixos"`（⚠️ 与 flake 名 legion 不同）
- `networking.networkmanager.enable = true`，`wifi.backend = "wpa_supplicant"`，`wifi.powersave = false`
- `services.timesyncd.enable = true`，`networking.timeServers = [ "ntp.aliyun.com" "ntp.tencent.com" ]`
- ⚠️ **防火墙已从本文件下放**：`daed.nix` 设 `checkReversePath = "loose"`；`mihomo.nix` 设 `trustedInterfaces = [ "Meta" ]` + 放行端口。不要在 network.nix 重复配置。

### 9. `system/services.nix`

**作用**：系统服务配置（最核心的服务文件）。

**包含内容**：
- `programs.dms-shell`（DankMaterialShell）：`enable = true`，systemd（`restartIfChanged = true`）、系统监控、动态主题、音频波长、VPN、日历事件全部开启
- ⚠️ 未启用 `services.xserver`（纯 Wayland；X 应用走 `xwayland-satellite`，AMD 图形由 `hardware.graphics` 提供）
- `services.dbus.enable = true`，`packages` 包含 `bluez`
- `services.power-profiles-daemon.enable = true`
- `services.gvfs.enable = true`，`services.tumbler.enable = true`
- `services.pipewire`：alsa（含 support32Bit）/pulse/jack/wireplumber 全部开启
- `security.rtkit.enable = true`
- `security.pam.services.greetd.enableGnomeKeyring = true`，`services.gnome.gnome-keyring.enable = true`
- `services.hermes-agent`（详见"五、Hermes Agent 专节"）
- `sops.templates."hermes-env"`（Hermes 环境变量模板）
- `systemd.tmpfiles.rules`：修复 hermes `auth.json` 属主（`/var/lib/hermes/.hermes/auth.json 0600 hermes hermes`）
- `systemd.services.hermes-agent.serviceConfig.TimeoutStopSec = 30`（网关排空需要更长停止超时）
- `services.upower.enable = true`，`services.pulseaudio.enable = false`，`services.blueman.enable = true`

### 10. `system/secrets.nix`

**内容**：
- `sops.defaultSopsFile = ../secrets/secrets.yaml`
- `sops.age.keyFile = "/etc/sops/age/keys.txt"`
- `sops.secrets`：
  - `deepseek_api_key = {}`、`vaultwarden_admin_token = {}`
  - `password_hash`：`neededForUsers = true`（activation 阶段先于用户创建解密，供 `hashedPasswordFile` 使用）
  - `vaultwarden_tls_ca_key` / `vaultwarden_tls_ca_crt` / `vaultwarden_tls_server_key` / `vaultwarden_tls_server_crt`：`path` 指向 `/var/lib/vaultwarden/tls/*`（boot 时 sops-nix 解密写入）

### 11. `system/fonts.nix`

**作用**：字体全套声明式配置（2026-08 大改：思源黑体/宋体取代 Noto CJK 主力）。

**内容**：
- `fonts.enableDefaultPackages = false`（默认字体包关闭，由 packages 完全接管）
- `fonts.packages`：`inter`、`source-serif`、`source-han-serif`（思源宋体）、`source-han-sans`（思源黑体）、`source-han-mono`（思源等宽）、`nerd-fonts.jetbrains-mono`、`noto-fonts-color-emoji`、`noto-fonts`
- `fonts.fontconfig.defaultFonts`：
  - sansSerif：`["Inter" "Source Han Sans SC" "Source Han Sans TC" "Noto Sans"]`
  - serif：`["Source Han Serif SC" "Source Han Serif TC" "Source Serif 4"]`
  - monospace：`["JetBrainsMono Nerd Font" "Source Han Mono SC" "Source Han Mono TC"]`
  - emoji：`["Noto Color Emoji"]`
- 渲染参数（macOS 观感）：`antialias = true`、`hinting.style = "slight"`、`subpixel.rgba = "rgb"`、`lcdfilter = "default"`
- `localConf`（写入 /etc/fonts/local.conf）：关 autohint/embeddedbitmap、`ui-*`/`-apple-system`/`SF Pro*` → Inter、`SF Mono` → JetBrainsMono Nerd Font、`Noto CJK*` → Source Han 分地区子家族映射

### 12. `system/input.nix`

**作用**：输入法配置（系统级 Fcitx5）。
- `i18n.inputMethod.type = "fcitx5"`，`waylandFrontend = true`
- addons：`fcitx5-rime`、`fcitx5-gtk`、`fcitx5-material-color`、`qt6Packages.fcitx5-chinese-addons`、`qt6Packages.fcitx5-configtool`

### 13. `system/xdg.nix`

**作用**：XDG 桌面门户。
- `xdg.portal.enable = true`，仅 `extraPortals = [ xdg-desktop-portal-gtk ]`
- `config.niri.default = [ "gtk" ]`

### 14. `system/greetd.nix`

**作用**：登录管理器（greetd + **tuigreet**，Wayland 会话）。
- `services.greetd.settings.default_session.command = "${pkgs.tuigreet}/bin/tuigreet --remember --asterisks --container-padding 2 --no-xsession-wrapper --cmd niri-session"`
- `user = "greeter"`
- `systemd.settings.Manager.DefaultTimeoutStopSec = "10s"`（防止关机卡住）
- greetd serviceConfig：`Type = "idle"`、tty 相关设置

### 15. `system/nix-ld.nix`（新增）

**作用**：**nix-ld 兼容动态链接器**，让非 Nix 二进制（AppImage 解压、.deb 解压的程序，如富途 futu、longbridge 等）通过 nix-ld 加载器找到系统库。

**关键内容**：
- `programs.nix-ld.enable = true`
- `libraries`：一整套 Electron/CEF（gtk3、glib、pango、cairo、harfbuzz、atk、gdk-pixbuf、fontconfig、freetype...）、媒体栈（libbsd、libgcrypt、librsvg、nss、cups、libdrm、mesa...）、X11/Qt（libx11~libxtst、xcbutil*、libsm、libice、dbus...）、通用基础（stdenv.cc.cc.lib、zlib、curl、openssl、icu、libGL）
- ⚠️ 自定义 `jpeg-8`（libjpeg.so.8 旧 ABI）：nixpkgs 的 libjpeg(turbo) 只提供 `.62`，libmpv 等旧库需要 `.8`，用 fetchurl 从 ijg.org 编译 `jpegsrc.v8d` 提供
- 缺库报错时往 `libraries` 里按需补充

### 16. `system/proxy/daed.nix`（主用）

**作用**：daed = dae（eBPF 高性能透明代理）+ Web 管理面板。eBPF 内核态分流，直连/分流性能优于用户态代理。

**关键内容**：
- `imports = [ inputs.daeuniverse.nixosModules.daed ]`
- `services.daed.enable = true`，面板监听 `127.0.0.1:2023`，tproxy 端口 12345
- `assetsPaths` 使用 **Loyalsoldier 增强版规则库**（`v2ray-rules-dat`，含 `geosite:gfw` 等分类）；默认的 `v2ray-domain-list-community` 无 gfw 分类会报 `code gfw not found`
- `networking.firewall.checkReversePath = "loose"`（dae 用 TPROXY 分流，回程流量需放行）
- ⚠️ **garnix 二进制缓存已注释禁用**：`cache.garnix.io` 时常 503 挂掉拖慢每次 rebuild；需要更新 daed/dae 时再临时启用，或本地编译

**flake 注意**：`daeuniverse` input **不能** `inputs.nixpkgs.follows`，且 nixpkgs 固定到 `b12141ef`（pnpm 10.x，daeuniverse 自测版本）；跟随最新 nixpkgs（pnpm 11+）会构建失败。本 input 固定 commit `42ece300`。

**日常使用**：
1. 访问 `http://127.0.0.1:2023` 打开面板（初始密码看 `systemctl status daed` 日志）
2. 初始化配置：tproxy_port 填 **12345**（与 `openFirewall.port` 一致）
3. 添加订阅 URL → 自动导入节点 → 配置 group / routing → 运行
4. 面板可网页内更新订阅、切换节点，无需改 nix 配置
5. 若报 `code xxx not found in geosite.dat`：确认 `/etc/daed/geosite.dat` 软链指向 `v2ray-rules-dat`（`ls -l /etc/daed/`），必要时 `systemctl restart daed`

**切换回 mihomo**：见 `mihomo.nix` 顶部注释（注释 daed import、取消 mihomo import）。

### 17. `system/proxy/mihomo.nix`（备用）

**作用**：mihomo（Clash Meta，TUN 模式），原主用方案，现为备用。

- `services.mihomo.enable = true`，`configFile = "${myvars.homeDirectory}/.config/mihomo/config.yaml"`（用户目录下，不在仓库内）
- `tunMode = true`，`webui = pkgs.metacubexd`
- `systemd.services.mihomo.path = [ pkgs.mihomo ]`（恢复系统默认高权限沙箱以完美支持 TUN）
- `networking.firewall`：`checkReversePath = "loose"`、`trustedInterfaces = [ "Meta" ]`、放行 TCP 9090/7890/7891
- 已自包含防火墙规则，启用时需同步在 `configuration.nix` 移除 dae import（反之亦然）

**订阅链接管理**（若启用）：
- 订阅链接在 `~/.config/mihomo/config.yaml` 的 `proxy-providers.mysub.url`（含 token，属敏感信息，不进 git）
- systemd 通过 `LoadCredential=config.yaml:...` 注入沙箱，mihomo 读注入副本
- **每月更换订阅**：编辑该文件 url → `systemctl restart mihomo` → `curl http://127.0.0.1:9090/providers/proxies` 验证
- 只刷新订阅（不改配置）：`curl -X PUT "http://127.0.0.1:9090/providers/proxies/mysub"`

### 18. `system/packages.nix`

**作用**：系统级软件包（所有用户可用）。

**完整列表**：
- **基础工具**：`wget`, `curl`, `git`, `lazygit`, `nh`, `jq`, `socat`, `tree`, `ripgrep`, `fd`, `bat`, `eza`
- **终端**：`alacritty`, `tmux`, `starship`, `fzf`, `zoxide`, `direnv`
- **压缩解压**：`zip`, `unzip`, `p7zip`, `rar`, `dtrx`
- **Nix 开发工具**：`nil`, `alejandra`, `statix`, `deadnix`, `nix-tree`, `nix-output-monitor`, `sops`, `age`
- **编译工具**：`gcc`, `gnumake`
- **Wayland / Niri**：`xwayland`, `xwayland-satellite`, `wl-clipboard`（⚠️ 截图已改用 niri 内置，grim/slurp/wl-clip-persist 已移除）
- **硬件检测**：`pciutils`, `ddcutil`
- **文件系统**：`btrfs-progs`, `ntfs3g`
- **网络兼容**：`wsdd`
- **Android**：`android-tools`（adb）
- **AppImage**：`appimage-run`（部分 AppImage 如 longbridge 依赖系统库，沙箱里没有，需 nix-ld 直跑，见 `system/nix-ld.nix`）
- **Secret**：`libsecret`
- **系统控制**：`playerctl`, `brightnessctl`, `libnotify`
- **编辑器**：`vim`, `gnome-text-editor`

### 19. `system/nvidia/nvidia-block.nix`（启用中）

**作用**：屏蔽 NVIDIA 独显以省电（仅用 AMD iGPU）。
- `boot.extraModprobeConfig`：blacklist nouveau
- `services.udev.extraRules`：移除 NVIDIA USB/音频/VGA 设备（power control）
- `boot.blacklistedKernelModules = [ "nouveau" "nvidia" "nvidia_drm" "nvidia_modeset" ]`

### 20. `system/nvidia/nvidia.nix`（未启用，保留备用）

**作用**：完整 NVIDIA 独显配置（future use）。
- `hardware.graphics.enable = true`
- 内核模块 `nvidia_modeset`/`nvidia_drm`/`nvidia`，blacklist nouveau
- `services.xserver = { enable = true; videoDrivers = [ "nvidia" ] }`（备用方案启用时自动开启 X11）
- `hardware.nvidia`：modesetting、`powerManagement.enable = false`、`open = false`、`nvidiaSettings = true`、`package = linuxPackages_latest.nvidiaPackages.stable`
- `hardware.nvidia.prime`：`sync.enable = true`，`amdgpuBusId = "PCI:6:0:0"`，`nvidiaBusId = "PCI:1:0:0"`
- ⚠️ **启用方法**：在 `configuration.nix` 的 imports 中把 `../../system/nvidia/nvidia-block.nix` 替换为 `../../system/nvidia/nvidia.nix`（二选一，不可同时启用）

### 21. `vars/default.nix`（新增）

**作用**：集中管理用户/仓库变量，经 `specialArgs` 以 `myvars` 注入所有模块。

**内容**：
- `username = "lilei"`、`userfullname = "lilei"`、`useremail = "lilei0918@gmail.com"`
- `homeDirectory = "/home/lilei"`
- `repoDir = "/home/lilei/nixos-DMS"`
- `flakeName = "legion"`

> 任何需要硬编码用户名/路径的地方，优先用 `myvars.xxx` 而不是写死字符串（fish/zsh 别名、mihomo configFile、thunar、firefox profile 等已改用）。

### 22. `tests/`（新增）

**作用**：flake 求值测试，`nix flake check` 自动运行（经 `checks.evalTestsCheck` 强制求值，失败即抛错）。

**结构**：每个测试子目录 `tests/<name>/` 下有 `expr.nix` + `expected.nix`，`tests/default.nix` 自动发现并断言二者相等。

**现有测试**：`home-directory`（home.homeDirectory == /home/lilei）、`state-version`、`timezone`（Asia/Shanghai）、`user-is-normal`。

**新增测试**：在 `tests/` 建目录，`expr.nix` 引用 `outputs.nixosConfigurations.legion.config...`，`expected.nix` 给出期望值。

### 23. `hosts/legion/home.nix`

**作用**：Home Manager 入口文件。

**关键内容**：
- `home.username = myvars.username`，`home.homeDirectory = myvars.homeDirectory`，`home.stateVersion = "25.05"`
- `imports` 列表包含：
  - `inputs.dms.homeModules.dank-material-shell`、`inputs.dms.homeModules.niri`
  - `inputs.niri.homeModules.niri`
  - `../../home/programs/rime.nix`、`vscode/vscode.nix`、`firefox.nix`、`chrome.nix`、`hermes.nix`、`walker.nix`、`thunar.nix`、`theme.nix`、`dconf.nix`、`fastfetch.nix`、`git.nix`、`btop.nix`、`AI/zed.nix`、`AI/opencode.nix`、`AI/pi.nix`
  - `../../home/terminal/alacritty.nix`、`fish.nix`、`starship.nix`、`tmux.nix`、`ghostty.nix`、`zsh.nix`
  - （`xfsettingsd.nix`、`reeden.nix` 未导入）
- **niri 包覆盖**：⚠️ `programs.niri.package = inputs.niri.packages.${...}.niri-stable`。系统 nixpkgs 的 `pkgs.niri` 引用了被删除的 `libdisplay-info_0_2`（nixpkgs 升 0.3 后），故改用 niri-flake 自带的包（其 nixpkgs 已在 flake.nix pin 到 624af66）。上游修复后可移除本行。
- `programs.niri.settings = import ../../home/niri/default.nix { inherit config pkgs inputs lib; }`
- `home.packages = lib.mkBefore allPackages`（`allPackages` 来自 `./packages.nix`）
- Fcitx5/Rime 用户配置：
  - `home.file."~/.local/share/fcitx5/rime/default.custom.yaml"`：schema `rime_ice`，`page_size: 9`
  - `xdg.configFile."fcitx5/profile"`：默认输入法 `rime`
  - ⚠️ fcitx 三件套环境变量（GTK_IM_MODULE/QT_IM_MODULE/XMODIFIERS/SDL_IM_MODULE）已统一移到 `home/programs/rime.nix`
- `home.sessionVariables`：`EDITOR=vim`
- `programs.direnv`：启用，`nix-direnv.enable = true`
- `programs.home-manager.enable = true`

### 24. `hosts/legion/packages.nix`

**作用**：用户级软件包列表（仅 lilei 可用）。

**完整列表**：
- **浏览器**：`google-chrome`
- **办公/阅读**：`libreoffice`, `foliate`, `loupe`, `zathura`, `zettlr`, **`thunderbird`**（邮件），**`papers`**（GNOME 文档阅读器）
- **金融**：`tradingview`
- **通讯**：`qq`, **`telegram-desktop`**
- **桌面配置**：`nwg-look`, `apple-cursor`, `waypaper`, `dconf-editor`, `matugen`, `qt6Packages.qt6ct`
- **文件管理**：`file-roller`, `localsend`
- **音频/视频**：`pavucontrol`, `mpv`, `gpu-screen-recorder`, `blanket`
- **音乐**：`spicetify-cli`（已注释，未启用）
- **笔记**：`siyuan`
- **图片**：`imagemagick`（已注释，未启用）

### 25. `home/programs/hermes.nix`

**作用**：安装 Hermes Desktop（CLI + GUI）。
```nix
{ pkgs, inputs, ... }: {
  home.packages = [ inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.desktop ];
  xdg.desktopEntries."hermes-desktop" = { ... }; # 声明桌面项，让 Hermes Desktop 出现在 walker / 应用菜单
}
```
- `desktop` 输出同时提供 CLI（hermes/hermes-agent/hermes-acp）和 `hermes-desktop` 启动器，复用 `~/.hermes/` 状态

### 26. `system/vault/vault.nix`（加密数据盘）

**作用**：管理 20G LUKS 加密盘（`/dev/nvme1n1p3`，LUKS UUID `86c742fc-8de5-4c59-9a30-196484a35695`），作为密码库 + 个人敏感文件存储。**手动按需解锁**，开机不自动挂载。

**关键内容**：
- `systemd.tmpfiles.rules` 常驻创建挂载点 `/mnt/vault`（加密卷关闭时也保留，便于 `mountpoint` 判断）
- `vault-open`（`writeShellApplication`，root）：`cryptsetup status` 未开 → `cryptsetup open "UUID=86c742fc-8de5-4c59-9a30-196484a35695" vault` → `mount /dev/mapper/vault /mnt/vault`，**幂等**（已开/已挂载则跳过）
- `vault-close`：先 `umount` 再 `cryptsetup close vault`
- `runtimeInputs` = `cryptsetup` + `util-linux`；用 **LUKS UUID** 而非设备路径，防设备号漂移

**使用**：
- 开：`sudo vault-open`；关：`sudo vault-close`
- 解锁后 `/mnt/vault` 是普通 ext4 目录，Thunar 可像普通盘一样复制粘贴管理
- 盘内目录结构：`vaultwarden/backups/`（备份归档）、`passwords/`、`recovery/`、`crypto/`、`ssh/`、`documents/`，详见盘中 `/mnt/vault/README.md`

### 27. `system/vault/vaultwarden.nix`

**作用**：自托管密码管理器（Vaultwarden = Bitwarden 服务端），通过 Podman 容器 + Quadlet 管理，SQLite 存储。

**关键内容**：
- `virtualisation.podman.enable = true`（Quadlet generator 随 podman 打包，`/etc/containers/systemd/*.container` 自动转 systemd 服务）；`dockerCompat = false`，`defaultNetwork.settings.dns_enabled = false`
- `systemd.timers.podman-auto-update.wantedBy = ["timers.target"]`：启用 podman 自带的自动更新 timer（配合容器 `AutoUpdate=registry`）
- 容器 `docker.io/vaultwarden/server:latest`，`AutoUpdate=registry`
- **数据持久化**：`/var/lib/vaultwarden`（宿主机）↔ `/data`（容器），SQLite 数据库即 `db.sqlite3`
- **仅本机访问**：`PublishPort=127.0.0.1:8080:80`
- **强制 HTTPS**：⚠️ Bitwarden 新版 web vault 拒绝所有 `http://` 请求（含 localhost）。本地 CA + localhost 证书（SAN 含 `DNS:localhost,IP:127.0.0.1`）由 sops 加密存储（`secrets.yaml` 的 `vaultwarden_tls_*`），boot 时 sops-nix 解密写入 `/var/lib/vaultwarden/tls`（0700 root）；Quadlet 用 `After=sops-nix.service` 确保容器在解密后启动，TLS 证书以 **bind mount 逐文件挂载**（sops 的 path 是符号链接，容器命名空间里没有 /run/secrets，需挂真实文件）。CA 公钥提交在仓库 `system/vault/certs/vaultwarden-ca.crt`，经 `security.pki.certificateFiles` 写入系统信任。证书稳定，rebuild 不轮换
- **访问地址**：`https://localhost:8080`（不是 http）
- 管理后台：`https://localhost:8080/admin`，密码为 sops 加密的 `vaultwarden_admin_token`（经 `sops.templates."vaultwarden-env"` 注入 `ADMIN_TOKEN`）
- `Environment`：`DOMAIN=https://localhost:8080`、`ROCKET_PORT=80`、`ROCKET_TLS=...`、**`SIGNUPS_ALLOWED=false`**（注册已关闭）、`WEBSOCKET_ENABLED=true`
- 容器 `TimeoutStopSec=60`（SQLite WAL checkpoint 需要优雅关闭，全局 10s 可能不够）
- 系统包补充：`podman`、`podman-compose`

**使用注意事项**：
- 若要开放注册：临时把 `SIGNUPS_ALLOWED` 改为 `true` → rebuild/重启容器 → 注册完改回 `false`
- 浏览器端：Firefox 已装 bitwarden 扩展；Chrome 用扩展或直接访问 web 界面
- 证书由 sops 管理，rebuild 不更换；**要换证书**：更新 `secrets.yaml` 的 `vaultwarden_tls_*`（并同步仓库 `certs/vaultwarden-ca.crt` 的公钥）→ rebuild → 重启容器
- `security.enterprise_roots.enabled = true` 已加入 firefox.nix，让 Firefox 使用系统根证书

### 28. `system/vault/vaultwarden-backup.nix`

**作用**：Vaultwarden 数据库每日在线备份（**三层**）。⚠️ Vaultwarden 新版已移除内置备份（`BACKUP_*` 变量无效），故用 `sqlite3 .backup` 在线备份（WAL 安全）。

**三层备份**：
1. **本地**：`sqlite3 .backup` → `/var/lib/vaultwarden/backups/backup-*.db`（保留 7 天）
2. **Arch 盘（自动镜像）**：systemd timer `vaultwarden-sync.timer`（`OnCalendar=daily` + `Persistent=true`，关机错过则开机补跑）→ 挂载 Arch btrfs 盘（`nvme0n1p7`，UUID `9dccd22a-c64e-494b-ab1a-e226b843516e`，`subvol=/` 顶层）rsync `--delete` 到 `@home/anan/Documents/vaultwarden-backup`（Arch 侧 `/home/anan/Documents/vaultwarden-backup`）后卸载
3. **加密盘（按需，长期归档）**：备份脚本末尾检测 `[ -b /dev/mapper/vault ] && mountpoint -q /mnt/vault`，已解锁则 rsync（**只增不删**）到 `/mnt/vault/vaultwarden/backups/`；未解锁自动跳过，不影响 Arch 那份

**使用**：
- 手动触发一次：`sudo systemctl start vaultwarden-sync`
- 三份备份分属两块物理盘（nvme0n1 Arch 盘 + nvme1n1 加密盘），单盘损坏不丢全部；加密盘副本作为长期归档，不随 7 天策略滚动删除

---

## 五、Hermes Agent 专节

### 配置位置
- **系统服务**：`system/services.nix` 中 `services.hermes-agent`
- **机密**：`system/secrets.nix` 声明 `deepseek_api_key`，实际值由 sops 加密存储在 `secrets/secrets.yaml`
- **环境变量**：`sops.templates."hermes-env"` 生成包含 `DEEPSEEK_API_KEY` 的环境文件

### 服务配置详情（system/services.nix）
```nix
services.hermes-agent = {
  enable = true;
  settings = {
    model.default = "deepseek-v4-flash";
    toolsets = [ "all" ];
    terminal = {
      backend = "local";
      timeout = 180;
    };
  };
  environmentFiles = [ config.sops.templates."hermes-env".path ];
  addToSystemPackages = true;
};

# 修复：auth.json 若属主是交互用户（lilei）则服务（hermes 用户）无法读取。
systemd.tmpfiles.rules = [
  "f /var/lib/hermes/.hermes/auth.json 0600 hermes hermes - -"
];

# 修复：网关排空（drain）需要更长停止超时（默认 10s 会在排空时 SIGKILL）。
systemd.services.hermes-agent.serviceConfig.TimeoutStopSec = 30;
```

### 使用方式
- **CLI**：`hermes` 或 `hermes-agent`（系统级命令，通过 `addToSystemPackages` 添加）
- **GUI**：应用菜单中 "Hermes Desktop"，或 `hermes-desktop`（由 Home Manager 安装，desktop entry 在 `home/programs/hermes.nix`）
- **临时切换模型**：`hermes --model deepseek-v4-pro`

### 密钥管理
- 编辑机密：`sops secrets/secrets.yaml`，添加 `deepseek_api_key: sk-你的真实密钥`（明文，保存后自动加密）
- 解密后的环境变量文件路径：`sudo cat $(readlink -f /run/secrets/hermes-env)`
- ⚠️ age 私钥 `/etc/sops/age/keys.txt`（信任根）已备份到 Win11 数据盘和 QQ 邮箱，**绝不可提交到 git**；备份/重装恢复步骤见「十二、关键注意事项」第 6 条

---

## 六、Niri 配置详解（home/niri/）

### default.nix（入口）
- 合并 `settings // keybinds // rules // autostart` 四个文件的属性集

### settings.nix（核心设置）
- **工作区**：⚠️ 现在用**数字前缀 + name** 声明三个命名工作区（key 决定顺序，name 为实际名）：
  ```
  workspaces = {
    "1-browser" = { name = "browser"; };
    "2-note"   = { name = "note"; };
    "3-code"   = { name = "code"; };
  };
  ```
  （`open-on-workspace` 不会自动创建工作区，必须在此声明，否则窗口落到当前工作区；terminal/media 工作区已移除）
- `prefer-no-csd = true`（禁用客户端装饰）
- `hotkey-overlay.skip-at-startup = true`
- **布局**：背景透明、focus-ring 启用（active `#ABC7FF` catppuccin Sapphire / inactive `#585b70` Surface2，width 1）、预设列宽 25/50/75/100%、默认列宽 75%、gaps 4、struts 8/8/1/1
- **输入**：键盘 us + numlock；触控板（tap、natural-scroll、two-finger、button-areas、middle-emulation、accel-profile adaptive）；`focus-follows-mouse.enable = true`、`warp-mouse-to-focus.enable = false`、`workspace-auto-back-and-forth = true`
- **输出**：`eDP-1` 1920×1080 @ 165.004Hz，scale 1.0
- **光标**：size 24、`hide-when-typing`、`hide-after-inactive-ms = 1000`
- **环境变量**（niri 会话内）：Wayland 全家桶（GDK/QT/MOZ/ELECTRON）、fcitx 四件套（GTK/QT/XMODIFIERS/GLFW）、QT_QPA_PLATFORMTHEME=gtk3（含 QT6）、XCURSOR_THEME=macOS-White

### keybinds.nix（快捷键）
| 按键 | 动作 |
|------|------|
| `super+q` | 关闭窗口 |
| `super+f` / `super+shift+f` | 全屏 / 最大化列 |
| `super+t` | 切换浮动 |
| `super+c` | 居中当前列 |
| `super+tab` | 切换到上一个工作区 |
| `super+1..4` | 列宽 25/50/75/100% |
| `super+return` | alacritty |
| `super+shift+return` | ghostty |
| `super+d` | walker（启动器） |
| `super+e` | thunar |
| `super+b` | google-chrome |
| `Print` | **niri 内置截图**（保存当前工作区到 `~/Pictures/Screenshots/`） |
| `Alt+Print` | 截图窗口 |
| `Ctrl+Print` | 截图全屏 |
| `Mod+P` | 截图（等同 Print） |

> ⚠️ **截图已改用 niri 内置动作**（`action.screenshot*`，Enter/Space 保存、Ctrl+Enter 复制到剪贴板），grim/slurp/wl-clip-persist 已移除。`config.lib.niri.actions` 是 niri-flake 缓存的旧清单不含 screenshot*，必须用 `action.<动作名>` 直接写 KDL 动作名。

### rules.nix（窗口规则）
- 通用圆角：`10 / 10 / 5 / 5`（左上/右上/左下/右下），`clip-to-geometry = true`
- Alacritty / Ghostty 固定列宽 800
- 浏览器类（google-chrome/firefox）`open-maximized`，分配到 `browser` 工作区
- 开发工具（Zed `dev.zed.Zed` / `codium`）占满列宽，分配到 `code` 工作区
- 办公/编辑器（libreoffice/zettlr/TradingView/gnome-text-editor）占满列宽
- 浮动类：FileRoller、pavucontrol、Blanket、LocalSend、dconf-editor、waypaper、nwg-look、qt6ct、Loupe、zathura、Foliate、Hermes（app-id `hermes`）、**telegram**
- **QQ**（app-id `QQ`）浮动 + 固定列宽 800（独立规则 6.1）
- 终端类（Alacritty/Ghostty/htop）与 mpv 均浮动、不分配工作区
- 弹窗类居中浮动（Open File/Save File）
- 画中画（Firefox PiP）右下角浮动 480×270
- SiYuan（app-id `org.b3log.siyuan`）→ `note` 工作区 + 独占一列 100%
- thunar（app-id `[Tt]hunar`）浮动 + 1200×800；**重命名对话框**（标题含 Rename/重命名）420×180 小浮动（规则 11.1 覆盖）

### autostart.nix（自启动）
- `xwayland-satellite`（XWayland 卫星服务）
- `polkit-gnome-authentication-agent-1`（权限代理）
- `fcitx5 -d`（输入法）
- `blueman-applet`（蓝牙托盘）
- `sleep 10 && exec qq`（延迟启动 QQ）
- ⚠️ `wl-clip-persist` 已移除（截图改用 niri 内置）

---

## 七、用户程序配置速查（home/programs/ 与 home/terminal/）

| 文件 | 内容要点 |
|------|---------|
| `AI/zed.nix` | Zed 编辑器（nixpkgs `zed-editor`，二进制 zeditor）+ **`nixd`**（Nix LSP，Zed 的 Nix 扩展需要）：**全声明式**——macOS Classic 主题（`theme.mode=system` 亮/暗自动切换）、5 个插件 auto_install_extensions（catppuccin-icons/git-firefly/html/macos-classic/nix）、vim 模式、minimap="never"、shell=fish（对象格式）、**ACP 链接 opencode**（`opencode acp`，⚠️ 不是 serve——serve 是 HTTP 服务器，Zed 连不上会一直 loading）。API key/登录走 Zed keychain（不进 Nix） |
| `AI/opencode.nix` | OpenCode AI agent（nixpkgs `opencode`）：**只装工具**，凭据用 `opencode auth login`（切换 provider 无需改 Nix） |
| `AI/pi.nix` | Pi coding agent（nixpkgs `pi-coding-agent`）：**只装工具**，认证用 `/login`（自动写入 `~/.pi/agent/auth.json`），自定义 provider 才需 `~/.pi/agent/models.json` |
| `alacritty.nix` | JetBrainsMono Nerd Font 12、Monokai Pro 配色、shell=fish、Ctrl+Shift+C/V、WINIT_UNIX_BACKEND=wayland |
| `ghostty.nix` | monokai-pro 主题（自定义 palette）、JetBrainsMono 12、无装饰、GTK tabs bottom |
| `fish.nix` | Nix 别名用**绝对路径**（`rebuild`/`nix-test`/`boot`/`rollback`/`cleanup`/`check`/`update`/`fmt`，任意目录可用）、g* git 别名、ls=eza 等、starship/direnv/zoxide/fzf、fzf-fish 插件、目录快捷 alias |
| `zsh.nix` | oh-my-zsh（git/sudo/colored-man-pages/extract）、syntaxHighlighting、历史 10 万、同名 Nix 别名（`rebuild`/`test`/`boot`/`rollback`/`cleanup`/`check`/`update`/`fmt`，绝对路径）、cd=z |
| `starship.nix` | 极简 format（user/host/dir/git/cmd_duration/❯） |
| `tmux.nix` | mouse、history 10 万、vi 模式键、escape-time 0 |
| `chrome.nix` | `~/.config/chrome-flags.conf`（注意是 **chrome**-flags 不是 chromium-flags，Google Chrome 品牌版只读前者）：Wayland ozone + 全套 GPU 加速 flag；LIBVA_DRIVER_NAME=radeonsi、VAAPI 相关环境变量 |
| `firefox.nix` | NUR 扩展（bitwarden/darkreader/sponsorblock）、隐私设置、搜索引擎（searxng/nix-packages/nixos-wiki/ddg，默认 ddg）、`security.enterprise_roots.enabled=true`（信任系统根证书，配合 Vaultwarden 本地 CA） |
| `git.nix` | user 信息走 myvars（lilei/lilei0918@gmail.com）、lfs、delta（Catppuccin Mocha、side-by-side）、别名 st/co/br/lg |
| `theme.nix` | GTK3 WhiteSur-Dark + WhiteSur 图标 + macOS-White 光标（含 `home.pointerCursor`）；**GTK4 用系统默认（`gtk4.theme = null`）**；Qt 走 gtk3；sessionVariables：`GTK_APPLICATION_PREFER_DARK_THEME=1`、XCURSOR_THEME/SIZE、`QT_QPA_PLATFORMTHEME=gtk3`（已删掉破坏 GTK4 的 `GTK_THEME`） |
| `dconf.nix` | gnome 桌面 WhiteSur 主题、Nerd Font 10 等宽字体 |
| `thunar.nix` | thunar + **xfconf**（必需）+ volman/archive/media-tags 插件、默认文件管理器（xdg.mimeApps）。默认显示隐藏文件、按名称升序且文件夹在前（`misc-folders-first`）、`force = true`（xfconf 改写文件破坏符号链接）。生效后需重启 Thunar（`killall Thunar`） |
| `walker.nix` | walker + elephant（剪贴板依赖，systemd user service，graphical-session.target 后启动） |
| `vscode/vscode.nix` | **VSCodium**：nix-ide、gitlens、material-icon、markdown-all-in-one、yaml、code-spell-checker（Nix LSP 统一用 nixd）。主题 **Catppuccin Mocha**。⚙️ Nix 格式化走 nixd：`nix.serverSettings.nixd.formatting.command = ["alejandra"]`。`redhat.telemetry.enabled=false` |
| `btop.nix` | presets、TTY 配色、desktop entry（ghostty -e btop） |
| `fastfetch.nix` | 自定义 logo（`assets/icons/logo.png`，type=auto、height 20、不设 width 自动缩放）+ 分组模块布局（Hardware/Software/Compositor） |
| `rime.nix` | rime-ice（锁定 commit `8a3d9470`，声明式 home.file 管理）+ librime/librime-lua；**fcitx 环境变量（GTK/QT/XMODIFIERS/SDL_IM_MODULE）统一在此管理**。⚠️ **rebuild/重启后若雾凇未出现，手动运行 `fcitx5-remote -r` 触发部署**（详见文件头注释） |

---

## 八、软件添加规范

### 1. 系统级软件（所有用户可用）
- 在 `system/packages.nix` 的 `environment.systemPackages` 中添加。
- 或者创建 `system/<name>.nix`（或相关主题目录，如 `system/nvidia/`、`system/vault/`、`system/proxy/`）并在 `configuration.nix` 的 `imports` 中引用。
- 重建：`sudo nixos-rebuild switch --flake .#legion`（或 `nh os switch .#legion`，nh 会自动提权，不要加 sudo）

### 2. 用户级软件（仅 lilei）
- 在 `home/programs/` 下创建 `<name>.nix`，内容通常为 `{ pkgs, ... }: { home.packages = [ pkgs.<name> ]; }` 或使用特定模块（如 `programs.git.enable = true`）。
- 然后在 `hosts/legion/home.nix` 的 `imports` 中添加 `../../home/programs/<name>.nix`。
- 也可直接在 `home.nix` 的 `home.packages` 中添加，但推荐模块化。
- ⚠️ 注意：新模块如果引用 flake input（如 `inputs.xxx`），必须先在 `flake.nix` 中添加对应 input，否则构建失败。
- 用户/路径等重复出现的值，优先用 `vars/default.nix` 的 `myvars` 而非写死字符串。

### 3. 添加新服务
- 在 `system/services.nix` 中添加相应的 `services.<name>.enable = true` 及配置。
- 如需环境变量，使用 `sops` 模板（如 `sops.templates."<name>-env"`）并设置 `environmentFiles`。

### 4. 添加新机密
- 在 `system/secrets.nix` 的 `secrets` 属性集中声明新密钥（如 `new_key = {};`）。
- 运行 `sops secrets/secrets.yaml` 添加对应条目（明文输入，保存后自动加密）。
- 在需要的地方使用 `config.sops.placeholder."new_key"` 或 `config.sops.secrets."new_key".path`。

### 5. 添加新测试
- 在 `tests/<name>/` 建 `expr.nix` + `expected.nix`（expr 取配置实际值，expected 给期望值），`tests/default.nix` 自动发现，`nix flake check` 自动校验。

---

## 九、系统更新与回滚

### 日常更新流程
1. 保存当前状态：`git add . && git commit -m "before update"`
2. 更新 flake 锁：`nix flake update`（或只更新某个 input：`nix flake lock --update-input <name>`）
   - ⚠️ `niri` / `hermes-agent` / `daeuniverse` 的 nixpkgs 是 pin 死的，`nix flake update` 不会动它们；要升级它们需手动改 flake.nix 里的 commit/url。
3. 测试构建（不切换）：`sudo nixos-rebuild test --flake .#legion`（或 `nh os test .#legion`）
4. 校验：`nix flake check`（跑 eval 测试 + pre-commit 的 alejandra/typos 检查）
5. 若测试通过，正式切换：`sudo nixos-rebuild switch --flake .#legion`（或 `nh os switch .#legion`）
6. 提交锁文件：`git add flake.lock && git commit -m "update inputs"`

### 回滚
- 回滚到上一个 generation：`sudo nixos-rebuild switch --rollback`
- 或在启动时从 systemd-boot 菜单选择旧 generation。

### 垃圾清理
- 删除所有旧 generation：`sudo nix-collect-garbage -d`
- 查看占用：`nix store gc --dry-run`
- fish/zsh 别名：`cleanup`（保留 14 天）；系统 GC 自动每日清理 3 天前 generation

### 特别注意（多系统引导）
由于主引导由 Arch GRUB 负责，更新 NixOS 的 `boot.nix` 配置时，需确保 `/boot/efi` 内的 `systemd-boot` 文件正确生成。若修改了 EFI 分区挂载选项或路径，可能需要同步更新 GRUB 配置（通常无需手动干预，因为 NixOS 的 `systemd-boot` 独立工作）。

---

## 十、常用命令速查

> 日常备查的完整备忘录见 [`MEMO.md`](./MEMO.md)（按主题分 Nix / 加密盘 / Vaultwarden / sops / 代理 / Hermes / 备份重装 / 排障）。

| 操作 | 命令 |
|------|------|
| 重建系统 | `sudo nixos-rebuild switch --flake .#legion`、`nh os switch .#legion` 或 `rebuild`（fish/zsh 别名，绝对路径，任意目录可用） |
| 仅测试 | `sudo nixos-rebuild test --flake .#legion`、`nh os test .#legion`、`nix-test`（fish）/ `test`（zsh） |
| 以新 generation 启动 | `nh os boot .#legion` 或 `boot` |
| 回滚 | `sudo nixos-rebuild switch --rollback` 或 `rollback` |
| 校验配置 | `nix flake check`（eval 测试 + pre-commit） |
| 进入开发环境 | `nix develop`（自动装 git pre-commit 钩子） |
| 查看 generations | `sudo nixos-rebuild list-generations` |
| 查看当前系统包 | `nix-store -q --references /run/current-system/sw` |
| 查看用户包 | `home-manager packages` |
| 搜索包 | `nix search nixpkgs <pkg>` |
| 更新所有 inputs | `nix flake update` 或 `update`（别名，绝对路径） |
| 更新单个 input | `nix flake lock --update-input <name>` |
| 查看 flake 元数据 | `nix flake metadata` |
| 清理垃圾 | `sudo nix-collect-garbage -d` 或 `cleanup`（保留 14 天） |
| 格式化配置 | `alejandra .` 或 `fmt` |
| 编辑机密 | `sops secrets/secrets.yaml` |
| 查看 Hermes 服务状态 | `systemctl status hermes-agent` |
| 查看 Hermes 日志 | `journalctl -u hermes-agent -f` |
| 检查 API Key 解密 | `cat $(readlink -f /run/secrets/hermes-env)` |
| 临时使用 Hermes CLI | `hermes "你好"` 或 `hermes --model deepseek-v4-pro` |
| 截图 | `Print` / `Alt+Print` / `Ctrl+Print`（niri 内置，保存到 `~/Pictures/Screenshots/`） |
| Git 推送 | `git push` |
| 查看系统状态 | `fastfetch` |
| 查看当前内核版本 | `uname -r` |
| 查看 NixOS 版本 | `nixos-version` |
| 打开加密盘（解锁+挂载） | `sudo vault-open` |
| 关闭加密盘（卸载+锁） | `sudo vault-close` |
| 手动触发 Vaultwarden 备份 | `sudo systemctl start vaultwarden-sync` |
| 备份信任根/凭据 | `sudo bash scripts/backup-credentials.sh`（到加密盘，默认保留 5 份） |
| 查看加密盘状态 | `cryptsetup status vault`、`lsblk /dev/nvme1n1p3` |
| 运行非 Nix 二进制 | 直接运行解压后的 AppImage/.deb（nix-ld 提供系统库），或 `appimage-run xxx.AppImage` |

---

## 十一、备忘

### 重装流程（恢复新机器）
0. **迁移前**：在旧机上解锁加密盘后备份信任根/凭据：`sudo bash scripts/backup-credentials.sh`（备份 `/etc/sops/age/keys.txt`、`~/.config/sops/age/keys.txt`、`~/.ssh/`、opencode `auth.json`）
1. **分区（二选一）**：
   - **disko 一键分区**（推荐）：在 NixOS 官方 ISO 中执行，只重建 `nvme1n1p2`（btrfs 根分区），**保留 DATATB 数据盘与加密盘**：
     ```bash
     git clone https://github.com/lilei0918/nixos-DMS.git && cd nixos-DMS

     # 保留 DATATB + 加密盘：只格式化+挂载 btrfs 根分区（分区表已存在）
     nix run github:nix-community/disko -- --mode format,mount hosts/legion/disko-fs.nix
     # 全新空盘（重建整块 nvme1n1 分区表，DATATB/加密盘不保留）：改用
     # nix run github:nix-community/disko -- --mode create,format,mount hosts/legion/disko-fs.nix
     # ⚠️ 不要用 --mode destroy（会销毁整块盘）

     # 挂载 Arch 共用 EFI（nvme0n1p6，UUID 9B06-514F；全新硬件需自行创建 EFI 分区并调整）
     mkdir -p /mnt/boot/efi
     mount /dev/disk/by-uuid/9B06-514F /mnt/boot/efi
     ```
   - **手动分区**：参照 `hosts/legion/hardware-configuration.nix`（Btrfs 子卷 `@/@home/@nix/@log`、`/tmp` tmpfs、EFI）
2. **放置 age 私钥**（在安装前写入目标系统，供激活阶段解密密码 hash）：
   ```bash
   mkdir -p /mnt/etc/sops/age
   cp /mnt/vault/credentials-backup/latest/etc-sops-age-keys.txt /mnt/etc/sops/age/keys.txt
   chmod 600 /mnt/etc/sops/age/keys.txt
   ```
3. **安装**（首次构建较慢；全新硬件需先 `nixos-generate-config --root /mnt` 并同步 `hardware-configuration.nix`）：
   ```bash
   nixos-install --root /mnt --flake .#legion --no-root-password
   reboot
   ```
4. 登录后 clone 仓库到 `/home/lilei/nixos-DMS`，放置 `~/.config/sops/age/keys.txt`，恢复 `~/.ssh/` 与 opencode `auth.json`
5. `sudo nixos-rebuild switch --flake .#legion`（或 `rebuild`）——密码 hash、Vaultwarden TLS 证书全部由 sops 自动解密生成，无需手动配置

### 未启用模块（保留但不导入）
- `system/nvidia/nvidia.nix`：完整独显配置，启用时替换 `nvidia-block.nix`（二选一，不可同时启用）。启用后会自动开启 `services.xserver`。
- `system/proxy/mihomo.nix`：mihomo 备用方案，启用时注释 daed.nix 的 import（二选一，不可同时开启）。
- `hosts/legion/packages.nix` 中 `spicetify-cli` / `imagemagick`（注释中）。
- `system/nix-ld.nix` 的 garnix 缓存（注释中，需要更新 daed/dae 时临时启用）。

### 设计说明
- 主机名 `nixos` ≠ flake 配置名 `legion`：所有 rebuild 命令用 `.#legion`；`hostname` 显示 `nixos` 属正常。
- niri 工作区：`settings.nix` 用数字前缀 key（`1-browser`/`2-note`/`3-code`）+ `name` 声明三个命名工作区（rules.nix 的 `open-on-workspace` 需要它们），其余工作区按需动态创建。
- mihomo 配置文件 `~/.config/mihomo/config.yaml` 在用户目录（非仓库内），需自行备份；daed 配置由面板管理（`/etc/daed/`），面板数据建议定期在面板内导出备份。
- 自定义脚本放 `~/.local/bin`（`environment.localBinInPath = true` 已加入 PATH），如 futu。

---

## 十二、关键注意事项

1. **多系统引导**：NixOS 的 `systemd-boot` 仅用于内部版本选择，主引导由 Arch 的 GRUB 管理。
2. **Btrfs 子卷**：系统使用 Btrfs 子卷布局（`@`, `@home`, `@nix`, `@log`），快照和回滚可基于此进行（当前未配置自动快照，但有 btrfs autoScrub）。
3. **无交换分区**：内存充足（32GB），因此未配置 swap。
4. **显卡驱动**：GPU 实际使用 AMD 核显（amdgpu），NVIDIA 独显被屏蔽（`nvidia-block.nix`）；`nvidia.nix` 保留完整独显配置，启用时二选一。系统为纯 Wayland，未启用 `services.xserver`（X 应用走 `xwayland-satellite`），`nvidia.nix` 启用时会自动开启。
5. **密码哈希**：存于 `secrets/secrets.yaml` 的 `password_hash`（sops 加密，不落仓库明文）。修改：用 `openssl passwd -6`（或 `mkpasswd -m sha-512`）生成新 hash → `sops secrets/secrets.yaml` 更新该值 → rebuild。
6. **sops 私钥（信任根）**：`/etc/sops/age/keys.txt`（对应公钥 `age14hwqm9aumaek4k6gn2zn8269ztzemgyvt8kqu4aq4lpxqtpl8uys5q42qn`）必须备份，丢了它 `secrets/secrets.yaml` 永远解不开。已备份到 win11 数据盘和 qqmail。用户级解密还依赖 `~/.config/sops/age/keys.txt`（跑 `sops secrets/secrets.yaml` 用），同样要备份。**推荐直接用备份脚本**（含上述两把 key + `~/.ssh/` + opencode `auth.json`）：
   ```bash
   sudo vault-open                      # 若加密盘未解锁
   sudo bash scripts/backup-credentials.sh   # 备份到 /mnt/vault/credentials-backup
   ```
   **手动备份命令**（现在执行）：
   ```bash
   sudo cp /etc/sops/age/keys.txt /mnt/vault/sops-age-keys.txt   # 或 U 盘等离线介质
   ```
   **重装恢复命令**（重装 NixOS 后、rebuild 前）：
   ```bash
   sudo mkdir -p /etc/sops/age
   sudo cp /path/to/sops-age-keys.txt /etc/sops/age/keys.txt
   sudo chown root:root /etc/sops/age/keys.txt
   sudo chmod 600 /etc/sops/age/keys.txt
   ```
   恢复后路径必须是 `/etc/sops/age/keys.txt`（`sops.age.keyFile` 指向它），之后 rebuild 即全自动：密码 hash、Vaultwarden TLS 证书全部由 sops 解密生成，无需其它手动步骤。
7. **镜像源**：已配置 Tuna/USTC 镜像，更新速度较快。daeuniverse 的 garnix 缓存已禁用（常 503）。
8. **NixOS 版本**：实际使用 unstable（当前 26.11，nixpkgs f13ff45），但 `system.stateVersion` 保留为 25.05 以确保兼容性。
9. **用户组**：`lilei` 已加入 `hermes` 组，这是使用 Hermes 服务的前提。
10. **机密文件**：`secrets/secrets.yaml` 已加密，可以提交到 GitHub，但 age 私钥绝不可提交（已在 `.gitignore` 中忽略）。
11. **Rime 部署**：rebuild/重启后若雾凇输入法未出现，手动运行 `fcitx5-remote -r` 触发部署（rime 目录由 home.file 声明式管理，部署懒触发）。详见 `home/programs/rime.nix` 头部注释。
12. **Vaultwarden 仅本机**：服务只监听 `127.0.0.1:8080`，firewall 无需放行；访问必须用 **`https://localhost:8080`**（Bitwarden 客户端拒绝 http）。
13. **注册已关闭**：`SIGNUPS_ALLOWED=false`，需要开放注册时临时改回 `true` 并重建/重启容器，用完再关。
14. **Vaultwarden 数据备份**：SQLite 数据在 `/var/lib/vaultwarden/db.sqlite3`，含全部密码（加密存储），备份该文件即备份整个保险库。
15. **Vaultwarden 证书**：本地 CA + 证书位于 `/var/lib/vaultwarden/tls/`（0700 root），由 sops 解密生成（`secrets.yaml` 的 `vaultwarden_tls_*`），rebuild 不轮换；CA 公钥 `system/vault/certs/vaultwarden-ca.crt` 经 `security.pki.certificateFiles` 写入系统信任，浏览器零警告无需手动导入。换证书流程见「vaultwarden.nix」一节。
16. **加密盘手动解锁**：LUKS 加密盘（`/dev/nvme1n1p3`，UUID `86c742fc-8de5-4c59-9a30-196484a35695`）开机**不自动挂载**，用 `sudo vault-open` / `sudo vault-close` 管理。**解锁密码 = 全部数据的钥匙**，丢失即永久丢失、无法找回，务必离线备份（纸质 / U 盘，参照 sops age key 的备份习惯）。
17. **加密盘用 Thunar 管理**：解锁挂载后 `/mnt/vault` 是普通 ext4 目录，可直接复制粘贴。**不要**用 udisks / GNOME Disks 解锁（会挂到动态路径 `/run/media/...`，破坏备份脚本对 `/mnt/vault` 的假设）。
18. **加密盘备份策略**：备份脚本第 3 层只在 vault 解锁时写入 `/mnt/vault/vaultwarden/backups/`（只增不删），未解锁自动跳过；加密盘内文件建议**定期外导**（U 盘等离线介质）再保一份。
19. **字体（思源）**：系统字体主力为 Source Han 思源黑体/宋体/等宽 + Inter + JetBrainsMono NF；`fonts.enableDefaultPackages = false`，fontconfig 的 `localConf` 做了 ui-*/SF Pro/Noto CJK → 思源的映射，改动注意保持 fontconfig 完整 XML。
20. **nixpkgs pin**：`niri`、`hermes-agent`（pin 624af66，libdisplay-info 0.2.0）、`daeuniverse`（pin b12141ef，pnpm 10.x）的 nixpkgs 是固定的，升级 nixpkgs 不会自动带上它们；要升级需手动改 flake.nix 并验证构建。home.nix 里 `niri-stable` 的 package 覆盖与其配套。
21. **nix-ld**：非 Nix 二进制（富途 futu、longbridge 等）依赖系统库，靠 `system/nix-ld.nix` 提供；缺库按报错往 `libraries` 补。自定义 `jpeg-8`（libjpeg.so.8 旧 ABI）是手动编译的，勿删。
22. **清理策略**：journal 上限 50M；`~/.cache/{uv,pip,nix,elephant}` 3 天自动清理（`system/cleanup.nix`）；系统 GC 每日自动删 3 天前 generation。
23. **截图**：已用 niri 内置截图（Print/Alt+Print/Ctrl+Print），保存到 `~/Pictures/Screenshots/`；grim/slurp/wl-clip-persist 已移除，旧文档中的 grim 命令不再适用。
24. **提交前检查**：`nix flake check` 会跑 eval 测试（`tests/`）和 pre-commit（alejandra --check + typos）。`git commit` 前确保 `.nix` 文件已 `alejandra .` 格式化，避免 typos 误报可改 `.typos.toml`。

---

## 十三、常见问题排查

- **启动后进入 GRUB 救援模式**：可能是 EFI 引导项丢失，需从 Arch 修复 GRUB 并重新生成配置，或手动添加 NixOS 的 EFI 文件。
- **NixOS 重建后无法引导新 generation**：检查 `/boot/efi/loader/entries/` 是否有新文件，以及 `systemd-boot` 配置是否正确。
- **Hermes 服务启动失败**：检查 API Key 是否解密（`cat /run/secrets/hermes-env`）、`/var/lib/hermes/.hermes/auth.json` 属主是否为 `hermes:hermes`（否则 `sudo systemctl restart hermes-agent` 后看日志）、模型名称是否正确、网络是否通畅。
- **`hermes: command not found`**：检查 `system/services.nix` 中 `addToSystemPackages = true` 是否设置，并确保已重建系统。
- **桌面没有 Hermes 图标**：检查 `home/programs/hermes.nix` 是否被 `home.nix` 正确导入，且已重建。
- **软件包未安装**：确认添加到了正确的层级（系统 vs 用户），并检查是否在正确的 `packages.nix` 中。
- **Git 冲突**：若从另一台机器修改并推送，拉取后需手动解决冲突，然后重建。
- **构建失败（磁盘空间不足）**：运行 `sudo nix-collect-garbage -d` 清理旧 generation。
- **启用模块报 input 不存在**：该模块引用了 flake.nix 中未定义的 input，先添加 input 再启用。
- **Vaultwarden 打不开/报证书错**：确认地址是 `https://localhost:8080`（非 http）；Chrome 需完全关闭重开加载新 CA；检查容器 `sudo systemctl restart vaultwarden.service`。
- **Vaultwarden 登录提示 Invalid master password**：先确认已注册账号（数据库 `/var/lib/vaultwarden/db.sqlite3` 的 `users` 表），再核对邮箱/密码；浏览器扩展的服务器地址填 `https://localhost:8080`。
- **`vault-open` / `vault-close` command not found**：脚本在 legion 配置（`system/vault/vault.nix`）中，尚未部署或部署的是旧 generation。临时用 `sudo nix-shell -p cryptsetup --run '...'` 命令，或 `nixos-rebuild switch --flake .#legion` 后重试。
- **`vault-close` 报 target is busy**：有程序正占用 `/mnt/vault`（通常是 Thunar/终端 cwd 在该目录），关掉窗口或 `cd` 离开后重试。可先 `lsof +D /mnt/vault` 查看占用进程。
- **加密盘解锁提示 wrong passphrase / 无法打开**：确认密码无误，且设备确实是对应分区（`sudo cryptsetup luksUUID /dev/nvme1n1p3` 应等于 `86c742fc-8de5-4c59-9a30-196484a35695`）。密码是唯一钥匙，无法找回。
- **非 Nix 二进制缺 .so 库**：把缺失的库包（如 `libxcb-*`、`qt6`）加进 `system/nix-ld.nix` 的 `libraries` 后 rebuild。libjpeg.so.8 由自定义 `jpeg-8` 提供。
- **daed 面板报 `code xxx not found in geosite.dat`**：确认 `/etc/daed/geosite.dat` 软链指向 `v2ray-rules-dat`（`ls -l /etc/daed/`），必要时 `systemctl restart daed`。
- **rebuild 时 daed 构建失败 / garnix 下载慢**：garnix 缓存已禁用，属正常；更新 daed/dae 时可临时启用 flake.nix 里注释的 garnix substituter，或本地编译。

---

## 十四、给 AI 助手的特别说明

- 此文档为静态知识库，AI 助手（Hermes / opencode 等）应以当前信息为基础回答用户问题。
- 当用户询问系统状态时，可参考"当前系统状态（快照）"部分，但动态值（如 uptime、generation 数）可能已变化，建议用户执行相应命令获取实时值。
- 所有操作建议需考虑多系统环境和硬件限制。
- 若用户要求添加/删除软件，应指明修改哪个文件，并提醒重建。
- 若涉及机密，应提醒用户使用 `sops` 编辑 `secrets/secrets.yaml`，而不是直接写入明文。
- 回答问题时，尽量引用具体的文件路径和配置示例。
- 用户/路径等常量优先引用 `vars/default.nix` 的 `myvars`。
- 行为规则见根目录 `AGENTS.md`；权限策略见 `agents/permissions.md`（含敏感文件 deny 清单）。
- 各子目录的轻量 `README.md` 是文件索引与要点，先就地读取，需要细节再回看本文档对应章节。
- **修改配置后应同步更新本文档**（目录树、模块说明、已知问题）及各子目录 `README.md`。

---

**文档版本**：5.1
**最后更新**：2026-08-16
**维护者**：lilei（AI 助手协助整理，基于仓库实际文件通读核实）
