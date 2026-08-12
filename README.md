改动配置的流程不变：
cd nixos-DMS
alejandra .
nix flake check 
git add -A && git commit -m "before switch"
nh os switch .#legion。

# nixos-DMS

Lei 的 NixOS 配置仓库（flake 化），目标主机：Lenovo Legion R7000P 2021。

## 技术栈

- **NixOS**：nixos-unstable（`system.stateVersion = 25.05`）
- **窗口管理器**：niri（滚动式 Wayland compositor）
- **桌面壳**：DankMaterialShell（dms）
- **登录**：greetd + tuigreet
- **Home Manager**：用户级配置（`home.stateVersion = 25.05`）
- **机密管理**：sops-nix（age 加密）

## 快速开始

```bash
# 切换系统（主机配置名 legion）
sudo nixos-rebuild switch --flake .#legion

# 或使用 nh（会自动提权，不要加 sudo）
nh os switch .#legion

# 仅测试构建，不切换
sudo nixos-rebuild test --flake .#legion
```

## 目录结构

```text
nixos-DMS/
├── flake.nix          # 入口：定义 inputs 和 outputs
├── Hermes.md          # AI 助手参考手册（配置详解）
├── hosts/legion/      # 主机专属配置
│   ├── configuration.nix   # NixOS 系统配置入口
│   ├── home.nix            # Home Manager 入口
│   └── packages.nix        # 用户级软件包
├── system/            # 系统级模块（nix/boot/hardware/network/services/fonts/input/...）
├── home/              # 用户级模块（niri/terminal/programs）
├── secrets/           # sops 加密的机密文件
└── assets/            # 图标与主题资源
```

## 主要特点

- AMD iGPU（amdgpu）驱动；NVIDIA 独显默认屏蔽（`nvidia-block.nix`），`nvidia.nix` 保留完整独显配置备用（启用时二者选其一）
- Btrfs 子卷布局（`@`/`@home`/`@nix`/`@log`），无 swap
- 多系统引导：Arch GRUB 主引导，NixOS systemd-boot 次引导
- Fcitx5 + Rime（rime-ice）输入法
- Tuna/USTC 镜像源加速
- Hermes Agent 系统服务（deepseek 模型，密钥走 sops）

## 注意事项

- `secrets/secrets.yaml` 已用 sops 加密，可安全提交；age 私钥（`/etc/sops/age/keys.txt`）**绝不可提交**
- 详细配置说明见 [`Hermes.md`](./Hermes.md)
