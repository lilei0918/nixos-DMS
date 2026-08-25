# system

系统级 NixOS 模块（影响所有用户），全部经 `hosts/legion/configuration.nix` 导入。

| 文件 | 职责 |
|------|------|
| `nix.nix`      | Nix 设置：flakes、Tuna/USTC 镜像、GC（每日删 3 天）、NUR overlay |
| `cleanup.nix`  | journal 上限 50M + `~/.cache` 用户缓存 tmpfiles 3 天清理 |
| `boot.nix`     | systemd-boot、`linuxPackages_latest`、内核参数 |
| `hardware.nix` | AMD 图形、蓝牙、fstrim、btrfs autoScrub |
| `network.nix`  | NetworkManager + NTP（防火墙已下放到 proxy/） |
| `services.nix` | DMS、PipeWire、GNOME Keyring（Hermes Agent 已移至 `home/programs/AI/hermes-service.nix`） |
| `secrets.nix`  | sops 机密声明（`defaultSopsFile = ../secrets/secrets.yaml`） |
| `fonts.nix`    | 思源黑体/宋体 + Inter + JetBrainsMono NF + fontconfig 映射 |
| `input.nix`    | Fcitx5 + Rime |
| `xdg.nix`      | xdg-desktop-portal-gtk |
| `greetd.nix`   | greetd + tuigreet（Wayland 登录） |
| `nix-ld.nix`   | nix-ld 动态链接器（非 Nix 二进制跑系统库 + 自定义 jpeg-8） |
| `packages.nix` | 系统级软件包清单 |
| `proxy/`       | daed（主用）/ mihomo（备用），二选一 |
| `nvidia/`      | nvidia-block（启用，屏蔽独显）/ nvidia.nix（备用） |
| `vault/`       | LUKS 加密盘 + Vaultwarden + 每日备份 |

关键注意：新增系统模块后在 `configuration.nix` 的 `imports` 引用；各文件要点见 `README.md`「四」。
