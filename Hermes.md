# NixOS Flake 配置说明（Hermes 参考手册 v3.0）

> **目标**：让 Hermes（AI 助手）理解这套 NixOS 配置的完整结构、硬件背景和日常维护流程，以便提供精准的操作建议。
> **本文档基于仓库实际文件内容整理（2026-08-01 通读核实），与配置仓库同步维护。**

---

## 一、硬件与系统概览

- **机型**：Lenovo Legion R7000P 2021（AMD 平台）
- **CPU**：AMD Ryzen 5 5600H（12 线程，基础频率 3.3GHz，最高 4.28 GHz）
- **GPU**：
  - 集成显卡：AMD Radeon Vega Series（当前驱动 `amdgpu`）
  - 独立显卡：NVIDIA（当前通过 `nvidia-block.nix` 屏蔽 Nouveau 和 nvidia 内核模块，未启用；`system/programs/nvidia.nix` 保留完整独显配置供日后启用）
- **内存**：32GB
- **存储**：
  - 原装 NVMe SSD（分区包含 Windows 11 和 Arch Linux）
  - 第二块 **1TB NVMe SSD**（用于 NixOS 及数据，Btrfs）
- **多系统引导**：Arch Linux 的 GRUB 作为主引导，管理三个系统（Arch、Win11、NixOS）。NixOS 自身使用 **systemd-boot** 作为次引导，用于选择 NixOS 的 generations。
- **主机名**：`nixos`（`system/network.nix` 中设置；flake 配置名才是 `legion`）
- **NixOS 用户**：仅 **`lilei`**（普通用户，加入 `wheel`、`networkmanager`、`video`、`input`、`hermes` 组）。
- **配置仓库**：`git@github.com:lilei0918/nixos-DMS.git`（本地路径 `/home/lilei/nixos-DMS`），已备份。

---

## 二、当前系统状态（快照）

> 数据核实于 2026-08-01，部分动态值会变化。以实际命令输出为准。

- **NixOS 版本**：26.11.20260726.624af66 (Zokor) —— 实际使用 nixpkgs unstable，`system.stateVersion` 设为 `25.05`
- **内核**：Linux 7.1.5（来自 `linuxPackages_latest`）
- **显示管理器**：greetd + **tuigreet**（Wayland 会话，`--cmd niri-session`）
- **窗口管理器**：niri v25.08（滚动式 Wayland compositor）
- **默认终端**：alacritty 0.17.0（`super+return`）；ghostty 为次选（`super+shift+return`）
- **当前 Shell**：fish 4.8.1（默认登录 shell 为 zsh，可自由切换；fish 是终端内的常用 shell）
- **系统 Generation**：48（2026-08-01 时 `/nix/var/nix/profiles/system-48-link`）
- **系统已安装天数**：4 天（从本次安装算起，/ 的 birth time）
- **Hermes 服务状态**：`hermes-agent` 运行中（active）

---

## 三、目录结构与职责

```text
nixos-DMS/
├── flake.nix                # 总入口，定义 inputs 和 outputs
├── flake.lock               # 锁定所有 inputs 版本
├── Hermes.md                # 本文档（参考手册）
├── .gitignore               # 忽略规则
├── .sops.yaml               # sops 加密规则（age key）
├── .nixcfg-ignore           # nh 工具的忽略规则
├── secrets/
│   └── secrets.yaml         # 加密的机密文件（sops，含 deepseek_api_key）
├── hosts/
│   └── legion/              # 主机专属配置（flake 配置名 legion）
│       ├── configuration.nix   # NixOS 系统配置（导入所有模块）
│       ├── hardware-configuration.nix  # 硬件自动生成（勿手动修改）
│       ├── home.nix            # Home Manager 入口
│       └── packages.nix        # 用户级软件包列表
├── system/                  # 系统级配置（影响所有用户）
│   ├── nix.nix              # Nix 自身设置（flakes、镜像源、GC、NUR overlay）
│   ├── boot.nix             # 启动引导（systemd-boot）
│   ├── hardware.nix         # 硬件：GPU 图形、蓝牙、fstrim、btrfs scrub
│   ├── network.nix          # 网络（NetworkManager、防火墙、NTP）
│   ├── services.nix         # 系统服务（DMS、PipeWire、Hermes Agent）
│   ├── secrets.nix          # sops 机密声明
│   ├── fonts.nix            # 字体配置
│   ├── input.nix            # 输入法（Fcitx5/Rime）
│   ├── xdg.nix              # XDG 桌面门户（gtk 后端）
│   ├── greetd.nix           # 登录管理器（greetd + tuigreet）
│   ├── mihomo.nix           # 代理（mihomo，TUN 模式）
│   ├── packages.nix         # 系统级软件包列表
│   └── programs/            # 系统程序模块
│       ├── nvidia-block.nix     # 【启用】屏蔽 NVIDIA 独显（省电）
│       └── nvidia.nix           # 【未启用】完整 NVIDIA 独显配置（prime sync，供日后启用）
├── home/                    # 用户级配置（仅 lilei）
│   ├── niri/                # Niri 窗口管理器配置
│   │   ├── default.nix      # 入口（合并 settings/keybinds/rules/autostart）
│   │   ├── settings.nix     # 核心设置（工作区、布局、输入、输出、环境变量）
│   │   ├── keybinds.nix     # 快捷键
│   │   ├── rules.nix        # 窗口规则
│   │   ├── applications.nix # 常用程序路径定义
│   │   └── autostart.nix    # 自动启动程序
│   ├── terminal/            # 终端相关
│   │   ├── alacritty.nix    # 主终端（Monokai Pro 配色、fish）
│   │   ├── ghostty.nix      # 次选终端（Monokai Pro 主题）
│   │   ├── fish.nix         # fish shell（别名、插件）
│   │   ├── zsh.nix          # zsh（oh-my-zsh、别名）
│   │   ├── starship.nix     # prompt
│   │   └── tmux.nix
│   └── programs/            # 用户软件包及配置
│       ├── btop.nix
│       ├── chrome.nix       # Google Chrome（Wayland + VA-API 硬解）
│       ├── cliphist.nix     # 剪贴板历史
│       ├── dconf.nix        # GNOME dconf 主题设置
│       ├── fastfetch.nix    # 系统信息（logo 指向 ~/nixos-DMS/assets/）
│       ├── firefox.nix      # Firefox（NUR 扩展、搜索配置）
│       ├── git.nix          # git + delta
│       ├── hermes.nix       # Hermes Desktop
│       ├── rime.nix         # Rime 输入法（rime-ice 方案）
│       ├── theme.nix        # GTK/Qt 主题（WhiteSur）
│       ├── thunar.nix       # 文件管理器
│       ├── vscode/          # VSCodium 配置（vscode.nix + vscode-settings.json）
│       ├── walker.nix       # 应用启动器（+ elephant 剪贴板依赖）
│       ├── obs.nix          # 【未启用】OBS Studio（VA-API 插件）
│       ├── xfsettingsd.nix  # 【未启用】XFCE 设置守护进程（home.nix 中已注释）
│       └── vscode/          # VSCodium 配置（vscode.nix + vscode-settings.json）
└── assets/                  # 静态资源
    ├── icons/               # 图标（nix-lavender.png 等）
    └── themes/base-16/      # base16 主题（gruvbox、noktis、oxocarbon 等）
```

---

## 四、核心配置文件详解

### 1. `flake.nix`

**作用**：定义所有输入源，输出 NixOS 配置。

**关键内容**：
- `inputs` 包含：
  - `nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"`
  - `home-manager`（follows nixpkgs）
  - `nur`（NUR 仓库）
  - `dms`（DankMaterialShell，`github:AvengeMedia/DankMaterialShell/stable`，follows nixpkgs）
  - `niri`（`github:sodiboo/niri-flake`，follows nixpkgs）
  - `hermes-agent`（固定 commit `1cdb8ce361e91c79cfbd6bee550ee6c09d290261`）
  - `sops-nix`（follows nixpkgs）
- `outputs`：`nixosConfigurations.legion` 使用 `nixpkgs.lib.nixosSystem`（system = `x86_64-linux`），传入 `specialArgs = { inherit self inputs; }`，并加载以下模块：
  - `./hosts/legion/configuration.nix`
  - `home-manager.nixosModules.default`
  - `hermes-agent.nixosModules.default`
  - `sops-nix.nixosModules.sops`
- `formatter.x86_64-linux` 使用 `alejandra`。

### 2. `hosts/legion/configuration.nix`

**作用**：主机入口，导入所有系统级模块并配置用户。

**关键内容**：
- `imports` 列表（按分组）：
  - 硬件：`./hardware-configuration.nix`
  - system 模块：`../../system/nix.nix`、`boot.nix`、`hardware.nix`、`network.nix`、`services.nix`
  - desktop：`fonts.nix`、`input.nix`、`xdg.nix`
  - programs：`../../system/programs/nvidia-block.nix`（注意：启用的是 block 不是 nvidia）、`mihomo.nix`、`packages.nix`
  - greeter：`greetd.nix`
  - secrets：`secrets.nix`
- 用户 `lilei`：`isNormalUser = true`，`shell = pkgs.zsh`，`extraGroups = [ "wheel" "networkmanager" "video" "input" "hermes" ]`，密码哈希固定。
- Home Manager 配置：`useGlobalPkgs = true`，`useUserPackages = true`，`extraSpecialArgs = { inherit inputs; }`（供 home.nix 等使用 flake inputs），`users.lilei = import ./home.nix`，备份扩展名 `backup`。
- `programs.dconf.enable = true`
- `time.timeZone = "Asia/Shanghai"`，`console.keyMap = "us"`
- `programs.zsh.enable = true`
- `system.stateVersion = "25.05"`
- `system.activationScripts.logRebuildTime` 写入 `/var/log/nixos-rebuild-log.json`（记录重建日期和 generation 号）。

### 3. `hosts/legion/hardware-configuration.nix`

**作用**：硬件自动生成（`nixos-generate-config`，勿手动修改）。

**关键内容**：
- 导入 `modulesPath + "/installer/scan/not-detected.nix"`
- `boot.initrd.availableKernelModules`：`nvme`, `xhci_pci`, `ahci`, `usbhid`, `usb_storage`, `sd_mod`
- 文件系统挂载（Btrfs 子卷，UUID `6c9764ff-c293-4be8-801c-982bdb6ed30a`）：
  - `/` → 子卷 `@`，`compress=zstd,noatime,discard=async`
  - `/home` → 子卷 `@home`
  - `/nix` → 子卷 `@nix`
  - `/var/log` → 子卷 `@log`
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
- `nix.gc`：自动，`dates = "daily"`，`options = "--delete-older-than 5d"`
- `nixpkgs.config.allowUnfree = true`

### 5. `system/boot.nix`

**内容**：
- `boot.loader.grub.enable = false`
- `boot.loader.systemd-boot`：`enable = true`，`configurationLimit = 5`
- `boot.loader.efi.efiSysMountPoint = "/boot/efi"`
- `boot.loader.efi.canTouchEfiVariables = false`
- `boot.tmp.cleanOnBoot = true`
- `boot.kernelPackages = pkgs.linuxPackages_latest`
- `boot.kernelParams = [ "amd_pstate=passive" "nowatchdog" ]`

### 6. `system/hardware.nix`

**内容**：
- `hardware.graphics.enable = true`，`extraPackages = [ libva libvdpau vulkan-loader vulkan-tools vulkan-validation-layers ]`
- `hardware.bluetooth`：`enable = true`，`powerOnBoot = true`
- `hardware.enableRedistributableFirmware = true`
- `services.udev.packages = [ pkgs.rwedid ]`
- `services.fstrim.enable = true`
- `services.btrfs.autoScrub.enable = true`

### 7. `system/network.nix`

**内容**：
- `networking.hostName = "nixos"`（⚠️ 与 flake 名 legion 不同）
- `networking.networkmanager.enable = true`，`wifi.backend = "wpa_supplicant"`，`wifi.powersave = false`
- `networking.firewall`：`trustedInterfaces = [ "Meta" ]`，`checkReversePath = "loose"`
- `services.timesyncd.enable = true`，`networking.timeServers = [ "ntp.aliyun.com" "ntp.tencent.com" ]`

### 8. `system/services.nix`

**作用**：系统服务配置（最核心的服务文件）。

**包含内容**：
- `programs.dms-shell`（DankMaterialShell）：`enable = true`，systemd、系统监控、动态主题、音频波长、VPN、日历事件全部开启
- `services.xserver`：启用，`videoDrivers = [ "amdgpu" ]`，`xkb.layout = "us"`
- `services.dbus.enable = true`，`packages` 包含 `bluez`
- `services.power-profiles-daemon.enable = true`
- `services.gvfs.enable = true`，`services.tumbler.enable = true`
- `services.pipewire`：alsa（含 support32Bit）/pulse/jack/wireplumber 全部开启
- `security.rtkit.enable = true`
- `security.pam.services.greetd.enableGnomeKeyring = true`，`services.gnome.gnome-keyring.enable = true`
- `services.hermes-agent`（详见"五、Hermes Agent 专节"）
- `sops.templates."hermes-env"`（Hermes 环境变量模板）
- `services.upower.enable = true`，`services.pulseaudio.enable = false`，`services.blueman.enable = true`

### 9. `system/secrets.nix`

**内容**：
- `sops.defaultSopsFile = ../secrets/secrets.yaml`
- `sops.age.keyFile = "/etc/sops/age/keys.txt"`
- `sops.secrets.deepseek_api_key = {}`

### 10. `system/fonts.nix`

**内容**：
- `fonts.fontDir.enable = true`
- `fonts.packages`：`noto-fonts-cjk-sans`、`noto-fonts-cjk-serif`、`noto-fonts-color-emoji`、`inter`、`fira-code`、`nerd-fonts.jetbrains-mono`、`noto-fonts`，以及 `lib.optionals` 条件加入的 `material-symbols` / `material-design-icons`
- `fonts.fontconfig`：
  - `defaultFonts`：sansSerif `["Noto Sans CJK SC" "Inter" "Noto Sans"]`；serif `["Noto Serif CJK SC" "Noto Serif"]`；monospace `["JetBrainsMono Nerd Font" "Noto Sans Mono CJK SC"]`；emoji `["Noto Color Emoji"]`
  - `antialias = true`，`hinting.enable = true`、`style = "slight"`，`subpixel.rgba = "none"`、`lcdfilter = "default"`

### 11. `system/input.nix`

**作用**：输入法配置（系统级 Fcitx5）。
- `i18n.inputMethod.type = "fcitx5"`
- `waylandFrontend = true`
- addons：`fcitx5-rime`、`fcitx5-gtk`、`fcitx5-material-color`、`qt6Packages.fcitx5-chinese-addons`、`qt6Packages.fcitx5-configtool`

### 12. `system/xdg.nix`

**作用**：XDG 桌面门户。
- `xdg.portal.enable = true`，仅 `extraPortals = [ xdg-desktop-portal-gtk ]`
- `config.niri.default = [ "gtk" ]`

### 13. `system/greetd.nix`

**作用**：登录管理器（greetd + **tuigreet**，Wayland 会话）。
- `services.greetd.settings.default_session.command = "${pkgs.tuigreet}/bin/tuigreet --remember --asterisks --container-padding 2 --no-xsession-wrapper --cmd niri-session"`
- `user = "greeter"`
- `systemd.settings.Manager.DefaultTimeoutStopSec = "10s"`（防止关机卡住）
- greetd serviceConfig：`Type = "idle"`、tty 相关设置

### 14. `system/mihomo.nix`

**作用**：代理服务（mihomo，TUN 模式）。
- `services.mihomo.enable = true`，`configFile = "/home/lilei/.config/mihomo/config.yaml"`（用户目录下，不在仓库内）
- `tunMode = true`，`webui = pkgs.metacubexd`
- `networking.firewall`：`trustedInterfaces = [ "mihomo" ]`，放行 TCP 9090/7890/7891

### 15. `system/packages.nix`

**作用**：系统级软件包（所有用户可用）。

**完整列表**：
- **基础工具**：`wget`, `curl`, `git`, `lazygit`, `nh`, `jq`, `socat`, `tree`, `ripgrep`, `fd`, `bat`, `eza`
- **终端**：`alacritty`, `tmux`, `starship`, `fzf`, `zoxide`, `direnv`
- **压缩解压**：`zip`, `unzip`, `p7zip`, `rar`, `dtrx`
- **Nix 开发工具**：`nil`, `alejandra`, `statix`, `deadnix`, `nix-tree`, `nix-output-monitor`, `sops`, `age`
- **编译工具**：`gcc`, `gnumake`
- **Wayland / Niri**：`xwayland`, `xwayland-satellite`, `grim`, `slurp`, `wl-clipboard`, `wl-clip-persist`
- **硬件检测**：`pciutils`, `ddcutil`
- **文件系统**：`btrfs-progs`, `ntfs3g`
- **网络兼容**：`wsdd`
- **Secret**：`libsecret`
- **系统控制**：`playerctl`, `brightnessctl`, `libnotify`
- **编辑器**：`vim`, `micro`

### 16. `system/programs/nvidia-block.nix`（启用中）

**作用**：屏蔽 NVIDIA 独显以省电（仅用 AMD iGPU）。
- `boot.extraModprobeConfig`：blacklist nouveau
- `services.udev.extraRules`：移除 NVIDIA USB/音频/VGA 设备（power control）
- `boot.blacklistedKernelModules = [ "nouveau" "nvidia" "nvidia_drm" "nvidia_modeset" ]`

### 17. `system/programs/nvidia.nix`（未启用，保留备用）

**作用**：完整 NVIDIA 独显配置（future use）。
- `hardware.graphics.enable = true`
- 内核模块 `nvidia_modeset`/`nvidia_drm`/`nvidia`，blacklist nouveau
- `services.xserver.videoDrivers = [ "nvidia" ]`
- `hardware.nvidia`：modesetting、`powerManagement.enable = false`、`open = false`、`nvidiaSettings = true`、`package = linuxPackages_latest.nvidiaPackages.stable`
- `hardware.nvidia.prime`：`sync.enable = true`，`amdgpuBusId = "PCI:6:0:0"`，`nvidiaBusId = "PCI:1:0:0"`
- ⚠️ **启用方法**：在 `configuration.nix` 的 imports 中把 `nvidia-block.nix` 替换为 `nvidia.nix`（二选一，不可同时启用）

### 18. `hosts/legion/home.nix`

**作用**：Home Manager 入口文件。

**关键内容**：
- `home.username = "lilei"`，`home.homeDirectory = "/home/lilei"`，`home.stateVersion = "24.11"`
- `imports` 列表包含：
  - `inputs.dms.homeModules.dank-material-shell`
  - `inputs.dms.homeModules.niri`
  - `inputs.niri.homeModules.niri`
  - `../../home/programs/rime.nix`
  - `../../home/programs/vscode/vscode.nix`
  - `../../home/programs/firefox.nix`
  - `../../home/programs/chrome.nix`
  - `../../home/programs/cliphist.nix`
  - `../../home/programs/hermes.nix`
  - `../../home/programs/walker.nix`
  - `../../home/programs/thunar.nix`
  - `../../home/programs/theme.nix`
  - `../../home/programs/dconf.nix`
  - `../../home/programs/fastfetch.nix`
  - `../../home/programs/git.nix`
  - `../../home/programs/btop.nix`
  - `../../home/terminal/alacritty.nix`
  - `../../home/terminal/fish.nix`
  - `../../home/terminal/starship.nix`
  - `../../home/terminal/tmux.nix`
  - `../../home/terminal/ghostty.nix`
  - `../../home/terminal/zsh.nix`
  - （`xfsettingsd.nix` 已被注释掉）
- `programs.niri.enable = true`，`settings = import ../../home/niri/default.nix { inherit config pkgs inputs lib; }`
- `home.packages = lib.mkBefore allPackages`（`allPackages` 来自 `./packages.nix`）
- Fcitx5/Rime 用户配置：
  - `home.file."~/.local/share/fcitx5/rime/default.custom.yaml"`：schema `rime_ice`，`page_size: 9`
  - `xdg.configFile."fcitx5/profile"`：默认输入法 `rime`
- `services.cliphist`：启用，`allowImages = true`
- `home.sessionVariables`：`EDITOR=vim`、fcitx 三件套（GTK_IM_MODULE/QT_IM_MODULE/XMODIFIERS）
- `programs.direnv`：启用，`nix-direnv.enable = true`
- `programs.home-manager.enable = true`

### 19. `hosts/legion/packages.nix`

**作用**：用户级软件包列表（仅 lilei 可用）。

**完整列表**：
- **浏览器**：`google-chrome`
- **办公/阅读**：`libreoffice`, `foliate`, `loupe`, `zathura`, `marktext`, `kdePackages.kate`
- **金融**：`tradingview`
- **通讯**：`qq`
- **桌面配置**：`nwg-look`, `apple-cursor`, `waypaper`, `dconf-editor`, `matugen`, `qt6Packages.qt6ct`
- **文件管理**：`file-roller`
- **音频/视频**：`pavucontrol`, `mpv`, `gpu-screen-recorder`, `blanket`
- **音乐**：`spicetify-cli`
- **笔记**：`siyuan`
- **图片**：`imagemagick`

### 20. `home/programs/hermes.nix`

**作用**：安装 Hermes Desktop（CLI + GUI）。
```nix
{ pkgs, inputs, ... }: {
  home.packages = [ inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.desktop ];
}
```
- `desktop` 输出同时提供 CLI（hermes/hermes-agent/hermes-acp）和 .desktop 启动器，复用 `~/.hermes/` 状态

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

sops.templates."hermes-env" = {
  content = ''
    DEEPSEEK_API_KEY=${config.sops.placeholder."deepseek_api_key"}
  '';
};
```

### 使用方式
- **CLI**：`hermes` 或 `hermes-agent`（系统级命令，通过 `addToSystemPackages` 添加）
- **GUI**：应用菜单中 "Hermes Agent"，或 `hermes-desktop`（由 Home Manager 安装）
- **临时切换模型**：`hermes --model deepseek-v4-pro`

### 密钥管理
- 编辑机密：`sops secrets/secrets.yaml`，添加 `deepseek_api_key: sk-你的真实密钥`（明文，保存后自动加密）
- 解密后的环境变量文件路径：`sudo cat $(readlink -f /run/secrets/hermes-env)`
- ⚠️ age 私钥 `/etc/sops/age/keys.txt` 已备份到 Win11 数据盘和 QQ 邮箱，**绝不可提交到 git**

---

## 六、Niri 配置详解（home/niri/）

### default.nix（入口）
- 合并 `settings // keybinds // rules // autostart` 四个文件的属性集

### settings.nix（核心设置）
- **工作区**：仅预定义 `"browser"`（niri 工作区是动态的，其他名称按需自动创建）
- `prefer-no-csd = true`（禁用客户端装饰）
- `hotkey-overlay.skip-at-startup = true`
- **布局**：背景透明、focus-ring 启用（active `#ABC7FF` catppuccin Sapphire，inactive `#585b70` Surface2）、预设列宽 25/50/75/100%、默认列宽 75%、gaps 4、struts 8/8/1/1
- **输入**：键盘 us + numlock；触控板（tap、natural-scroll、two-finger、button-areas、middle-emulation）；`focus-follows-mouse.enable = true`；`workspace-auto-back-and-forth = true`
- **输出**：`eDP-1` 1920×1080 @ 165.004Hz，scale 1.0
- **光标**：size 24、`hide-when-typing`、`hide-after-inactive-ms = 1000`
- **环境变量**（niri 会话内）：Wayland 全家桶（GDK/QT/MOZ/ELECTRON）、fcitx 三件套 + GLFW_IM_MODULE、QT_QPA_PLATFORMTHEME=gtk3、XCURSOR_THEME=macOS-White

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
| `print` / `alt+print` / `ctrl+print` | grim+slurp 截图（区域/窗口/全屏）→ wl-copy |

### rules.nix（窗口规则）
- 通用圆角 20px（所有窗口）
- Alacritty/Ghostty 固定列宽 800
- 浏览器类（zen/firefox/chromium/edge/chrome）`open-maximized`
- 开发类（Zed/Chrome/VSCodium/Trae/codium）列宽 100%
- 浮动类：Telegram、FileRoller、tauonmb、wechat、QQ、thunar
- 弹窗类居中浮动（is-floating、Open/Save File、xdg-desktop-portal-gnome）
- 画中画（Firefox/Zen）右下角浮动 480×270
- 按工作区分派：code→"code"、ghostty→"terminal"、mpv→"media"（浮动）、htop→"terminal"
- SiYuan 独占一列 100%
- thunar 浮动 + 1200×800

### applications.nix（程序路径）
- `browser = google-chrome`，`terminal = ghostty`，`fileManager = thunar`，`appLauncher = walker`
- 截图命令封装（grim + slurp + wl-copy）

### autostart.nix（自启动）
- `xwayland-satellite`（XWayland 卫星服务）
- `polkit-gnome-authentication-agent-1`（权限代理）
- `fcitx5 -d`（输入法）
- `wl-paste --watch cliphist store`（剪贴板监听）
- `blueman-applet`（蓝牙托盘）
- `wl-clip-persist --clipboard regular`（剪贴板持久化，延迟 2s）
- `sleep 10 && exec qq`（延迟启动 QQ）

---

## 七、用户程序配置速查（home/programs/ 与 home/terminal/）

| 文件 | 内容要点 |
|------|---------|
| `alacritty.nix` | JetBrainsMono Nerd Font 12、Monokai Pro 配色、shell=fish、Ctrl+Shift+C/V |
| `ghostty.nix` | monokai-pro 主题、JetBrainsMono 14、无装饰、GTK tabs bottom |
| `fish.nix` | 别名（rebuild/nix-test/boot=nh os .#legion、g* git 别名、ls=eza 等）、starship/direnv/zoxide/fzf、fzf-fish 插件、目录快捷 alias |
| `zsh.nix` | oh-my-zsh（git/sudo/colored-man-pages/extract）、syntaxHighlighting、历史 10 万、同名 Nix 别名、cd=z |
| `starship.nix` | 极简 format（user/host/dir/git/cmd_duration/❯） |
| `tmux.nix` | mouse、history 10 万、vi 模式键、escape-time 0 |
| `chrome.nix` | chromium-flags.conf：Wayland ozone + 全套 GPU 加速 flag；LIBVA_DRIVER_NAME=radeonsi、VAAPI 相关环境变量 |
| `firefox.nix` | NUR 扩展（bitwarden/darkreader/sponsorblock）、隐私设置、搜索引擎（searxng/nix-packages/nixos-wiki/ddg，默认 ddg） |
| `git.nix` | user lilei/lilei0918@gmail.com、lfs、delta（Catppuccin Mocha）、别名 st/co/br/lg |
| `theme.nix` | GTK WhiteSur-Dark + WhiteSur 图标 + macOS-White 光标、Qt 走 gtk3、GTK4 用系统默认（gtk4.theme = null）、GTK_APPLICATION_PREFER_DARK_THEME=1 |
| `dconf.nix` | gnome 桌面 WhiteSur 主题、Nerd Font 10 等宽字体 |
| `thunar.nix` | thunar + volman/archive/media-tags 插件、默认文件管理器、图标视图配置 |
| `walker.nix` | walker + elephant（剪贴板依赖，systemd user service） |
| `vscode/vscode.nix` | **VSCodium**（不是 VSCode）：nix-ide、gitlens、material-icon、material-theme、markdown-all-in-one、yaml、code-spell-checker；首次激活时复制 vscode-settings.json |
| `btop.nix` | presets、TTY 配色、desktop entry（ghostty -e btop） |
| `fastfetch.nix` | 自定义 logo 与模块布局（logo 指向 ~/nixos-DMS/assets/） |
| `rime.nix` | rime-ice（锁定 commit `8a3d9470`，声明式 home.file 管理）、librime + librime-lua。⚠️ **rebuild/重启后若雾凇未出现，手动运行 `fcitx5-remote -r` 触发部署**（详见文件头注释） |
| `cliphist.nix` | 剪贴板历史（允许图片） |
| `obs.nix` | 【未启用】wrapOBS + obs-vkcapture/webgtk/vaapi/composite-blur 插件 |
| `xfsettingsd.nix` | 【未启用】XFCE 设置守护进程 user service |

---

## 八、软件添加规范

### 1. 系统级软件（所有用户可用）
- 在 `system/packages.nix` 的 `environment.systemPackages` 中添加。
- 或者创建 `system/programs/<name>.nix` 并在 `configuration.nix` 的 `imports` 中引用。
- 重建：`sudo nixos-rebuild switch --flake .#legion`（或 `nh os switch .#legion`，nh 会自动提权，不要加 sudo）

### 2. 用户级软件（仅 lilei）
- 在 `home/programs/` 下创建 `<name>.nix`，内容通常为 `{ pkgs, ... }: { home.packages = [ pkgs.<name> ]; }` 或使用特定模块（如 `programs.git.enable = true`）。
- 然后在 `hosts/legion/home.nix` 的 `imports` 中添加 `../../home/programs/<name>.nix`。
- 也可直接在 `home.nix` 的 `home.packages` 中添加，但推荐模块化。
- ⚠️ 注意：新模块如果引用 flake input（如 `inputs.xxx`），必须先在 `flake.nix` 中添加对应 input，否则构建失败（如 spicetify.nix、zen.nix 的教训）。

### 3. 添加新服务
- 在 `system/services.nix` 中添加相应的 `services.<name>.enable = true` 及配置。
- 如需环境变量，使用 `sops` 模板（如 `sops.templates."<name>-env"`）并设置 `environmentFiles`。

### 4. 添加新机密
- 在 `system/secrets.nix` 的 `secrets` 属性集中声明新密钥（如 `new_key = {};`）。
- 运行 `sops secrets/secrets.yaml` 添加对应条目（明文输入，保存后自动加密）。
- 在需要的地方使用 `config.sops.placeholder."new_key"` 或 `config.sops.secrets."new_key".path`。

---

## 九、系统更新与回滚

### 日常更新流程
1. 保存当前状态：`git add . && git commit -m "before update"`
2. 更新 flake 锁：`nix flake update`（或只更新某个 input：`nix flake lock --update-input <name>`）
3. 测试构建（不切换）：`sudo nixos-rebuild test --flake .#legion`（或 `nh os test .#legion`）
4. 若测试通过，正式切换：`sudo nixos-rebuild switch --flake .#legion`（或 `nh os switch .#legion`）
5. 提交锁文件：`git add flake.lock && git commit -m "update inputs"`

### 回滚
- 回滚到上一个 generation：`sudo nixos-rebuild switch --rollback`
- 或在启动时从 systemd-boot 菜单选择旧 generation。

### 垃圾清理
- 删除所有旧 generation：`sudo nix-collect-garbage -d`
- 查看占用：`nix store gc --dry-run`
- fish/zsh 别名：`cleanup`（保留 14 天）

### 特别注意（多系统引导）
由于主引导由 Arch GRUB 负责，更新 NixOS 的 `boot.nix` 配置时，需确保 `/boot/efi` 内的 `systemd-boot` 文件正确生成。若修改了 EFI 分区挂载选项或路径，可能需要同步更新 GRUB 配置（通常无需手动干预，因为 NixOS 的 `systemd-boot` 独立工作）。

---

## 十、常用命令速查

| 操作 | 命令 |
|------|------|
| 重建系统 | `sudo nixos-rebuild switch --flake .#legion`、`nh os switch .#legion` 或 `rebuild`（fish 别名） |
| 仅测试 | `sudo nixos-rebuild test --flake .#legion`、`nh os test .#legion` 或 `nix-test` |
| 查看 generations | `sudo nixos-rebuild list-generations` |
| 查看当前系统包 | `nix-store -q --references /run/current-system/sw` |
| 查看用户包 | `home-manager packages` |
| 搜索包 | `nix search nixpkgs <pkg>` |
| 更新所有 inputs | `nix flake update` |
| 更新单个 input | `nix flake lock --update-input <name>` |
| 查看 flake 元数据 | `nix flake metadata` |
| 清理垃圾 | `sudo nix-collect-garbage -d` 或 `cleanup` |
| 格式化配置 | `alejandra .` 或 `fmt` |
| 编辑机密 | `sops secrets/secrets.yaml` |
| 查看 Hermes 服务状态 | `systemctl status hermes-agent` |
| 查看 Hermes 日志 | `journalctl -u hermes-agent -f` |
| 检查 API Key 解密 | `cat $(readlink -f /run/secrets/hermes-env)` |
| 临时使用 Hermes CLI | `hermes "你好"` 或 `hermes --model deepseek-v4-pro` |
| Git 推送 | `git push` |
| 查看系统状态 | `fastfetch` |
| 查看当前内核版本 | `uname -r` |
| 查看 NixOS 版本 | `nixos-version` |

---

## 十一、已知问题与待办（⚠️ 重要）

### ✅ 已修复（2026-08-01）
1. ~~fastfetch logo 路径错误~~：已改为 `~/nixos-DMS/assets/icons/nix-lavender.png`
2. ~~`super+v` 快捷键失效~~：已删除该绑定（用户不需要此快捷键）
3. ~~home.nix 重复导入~~：`fastfetch.nix` 和 `vscode/vscode.nix` 各保留一次导入
4. ~~spicetify.nix / zen.nix~~：已删除（引用了不存在的 flake input，用户不使用）
5. ~~polkitgnome.nix~~：已删除（与 autostart.nix 的 polkit spawn 重复）
6. ~~批量清理~~：niri-colors.generated.kdl 移出 git 跟踪、vesktop 死规则删除、工作区完全动态、mihomo 无效接口清理、dconf 字体名修正、rime-ice 锁定 commit、home.stateVersion 24.11→25.05、README.md 新建
7. ~~hermes-desktop 无启动器~~：`home/programs/hermes.nix` 增加 `xdg.desktopEntries`（walker/应用菜单可见）
8. ~~auth.json 权限错误~~：`system/services.nix` 增加 tmpfiles 规则（`f .../auth.json 0600 hermes hermes`），修复 lilei 属主 600 文件导致 hermes 服务无法读取的问题
9. ~~TimeoutStopSec 默认 10s~~：`system/services.nix` 设置 `systemd.services.hermes-agent.serviceConfig.TimeoutStopSec = 30`，避免网关排空时被 SIGKILL

### 未启用模块（保留但不导入）
- `system/programs/nvidia.nix`：完整独显配置，启用时替换 `nvidia-block.nix`（二选一，不可同时启用）。
- `home/programs/obs.nix`：OBS 配置，可用但未在 home.nix 导入。
- `home/programs/xfsettingsd.nix`：XFCE 设置守护进程，home.nix 中已注释。

### 设计说明
- 主机名 `nixos` ≠ flake 配置名 `legion`：所有 rebuild 命令用 `.#legion`；`hostname` 显示 `nixos` 属正常。
- niri 工作区完全动态（`settings.nix` 不预定义任何工作区），rules.nix 引用的 `code`/`terminal`/`media` 工作区在首次使用时自动创建。
- mihomo 配置文件 `/home/lilei/.config/mihomo/config.yaml` 在用户目录（非仓库内），需自行备份。

---

## 十二、关键注意事项

1. **多系统引导**：NixOS 的 `systemd-boot` 仅用于内部版本选择，主引导由 Arch 的 GRUB 管理。
2. **Btrfs 子卷**：系统使用 Btrfs 子卷布局（`@`, `@home`, `@nix`, `@log`），快照和回滚可基于此进行（当前未配置自动快照，但有 btrfs autoScrub）。
3. **无交换分区**：内存充足（32GB），因此未配置 swap。
4. **显卡驱动**：GPU 实际使用 AMD 核显（amdgpu），NVIDIA 独显被屏蔽（`nvidia-block.nix`）；`nvidia.nix` 保留完整独显配置，启用时二选一。
5. **密码哈希**：用户密码固定，如要更改请重新生成哈希并替换。
6. **sops 私钥**：`/etc/sops/age/keys.txt` 必须备份，否则无法解密 `secrets.yaml`（已备份到 win11 的数据盘和 qqmail）。
7. **镜像源**：已配置 Tuna/USTC 镜像，更新速度较快。
8. **NixOS 版本**：实际使用 unstable（当前 26.11），但 `system.stateVersion` 保留为 25.05 以确保兼容性。
9. **用户组**：`lilei` 已加入 `hermes` 组，这是使用 Hermes 服务的前提。
10. **机密文件**：`secrets/secrets.yaml` 已加密，可以提交到 GitHub，但 age 私钥绝不可提交（已在 `.gitignore` 中忽略）。
11. **Rime 部署**：rebuild/重启后若雾凇输入法未出现，手动运行 `fcitx5-remote -r` 触发部署（rime 目录由 home.file 声明式管理，部署懒触发）。详见 `home/programs/rime.nix` 头部注释。

---

## 十三、常见问题排查

- **启动后进入 GRUB 救援模式**：可能是 EFI 引导项丢失，需从 Arch 修复 GRUB 并重新生成配置，或手动添加 NixOS 的 EFI 文件。
- **NixOS 重建后无法引导新 generation**：检查 `/boot/efi/loader/entries/` 是否有新文件，以及 `systemd-boot` 配置是否正确。
- **Hermes 服务启动失败**：检查 API Key 是否解密（`cat /run/secrets/hermes-env`），模型名称是否正确，网络是否通畅。
- **`hermes: command not found`**：检查 `system/services.nix` 中 `addToSystemPackages = true` 是否设置，并确保已重建系统。
- **桌面没有 Hermes 图标**：检查 `home/programs/hermes.nix` 是否被 `home.nix` 正确导入，且已重建。
- **软件包未安装**：确认添加到了正确的层级（系统 vs 用户），并检查是否在正确的 `packages.nix` 中。
- **Git 冲突**：若从另一台机器修改并推送，拉取后需手动解决冲突，然后重建。
- **构建失败（磁盘空间不足）**：运行 `sudo nix-collect-garbage -d` 清理旧 generation。
- **启用模块报 input 不存在**：该模块引用了 flake.nix 中未定义的 input（如 spicetify-nix、zen-browser），先添加 input 再启用。

---

## 十四、给 Hermes 的特别说明

- 此文档为静态知识库，Hermes 应以当前信息为基础回答用户问题。
- 当用户询问系统状态时，可参考"当前系统状态（快照）"部分，但动态值（如 uptime、generation 数）可能已变化，建议用户执行相应命令获取实时值。
- 所有操作建议需考虑多系统环境和硬件限制。
- 若用户要求添加/删除软件，应指明修改哪个文件，并提醒重建。
- 若涉及机密，应提醒用户使用 `sops` 编辑 `secrets/secrets.yaml`，而不是直接写入明文。
- 回答问题时，尽量引用具体的文件路径和配置示例。
- **修改配置后应同步更新本文档**（目录树、模块说明、已知问题）。

---

**文档版本**：3.1
**最后更新**：2026-08-01
**维护者**：lilei（Hermes 协助整理，基于仓库实际文件通读核实）
