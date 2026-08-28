# system/nvidia

NVIDIA 独显模块。**二选一，不可同时启用**，由 `vars/default.nix` 的 `myvars.enableNvidia` 自动切换（见 `hosts/legion/configuration.nix`）。

- `nvidia-block.nix`【默认，`enableNvidia = false`】屏蔽 NVIDIA 独显（blacklist nouveau/nvidia + udev 移除 PCI 设备），仅用 AMD iGPU（Cezanne Vega）省电
- `nvidia.nix`      【`enableNvidia = true`】启用 NVIDIA 驱动（RTX 3060）：PRIME offload 按需渲染 + RTD3 空闲断电 + `powerManagement`（suspend 存 VRAM）+ 开源内核模块（`open = true`）

切换方法：`vars/default.nix` 改 `enableNvidia` 后 `nh os switch .#legion` 即可，无需改动 `configuration.nix`。

## 独显使用方式（offload 模式）

平时 niri / 浏览器 / 视频全部走 AMD 核显（省电）；需要独显时用 `nvidia-offload` 包装命令：

```bash
nvidia-offload <cmd>                 # 任意命令
# Steam 启动项: nvidia-offload %command%
# 加 GameMode:  nvidia-offload gamemoderun %command%
# Heroic/Lutris: 在对应启动项前缀加 nvidia-offload
```

电源键 LED 联动：EC `platform_profile` 由 `system/services.nix` 的 `quiet-fan-*` 服务在 initrd/开机/唤醒三处强制 `low-power`（蓝灯，静音）；PPD 档位（DMS bar 显示）开机强制回 `power-saver`。

详见根 `README.md`「四」第 19 / 20 节。
