# hosts

主机专属配置（flake 配置名：`legion`）。

- `legion/` — 当前唯一主机（Lenovo Legion R7000P 2021）
  - `configuration.nix`   NixOS 系统入口：导入全部 system 模块、用户配置、DATATB 自动挂载
  - `hardware-configuration.nix`  `nixos-generate-config` 生成，勿手动修改
  - `home.nix`            Home Manager 入口（导入 home/ 模块，niri 手写 KDL 配置）
  - `packages.nix`        用户级软件包清单

详细说明见根目录 `README.md`「四」第 2 / 3 / 23 / 24 节。
