# system/nvidia

NVIDIA 独显模块。**二选一，不可同时启用**（在 `configuration.nix` 的 `imports` 中切换）。

- `nvidia-block.nix` 【当前启用】屏蔽 NVIDIA 独显（blacklist nouveau/nvidia），仅用 AMD iGPU 省电
- `nvidia.nix`       【未启用】完整 NVIDIA 配置（prime sync、nvidiaSettings），启用时自动开启 `services.xserver`

详见 `README.md`「四」第 19 / 20 节。
