# hosts/legion

主机 legion（Lenovo Legion R7000P 2021）专属配置。flake 配置名 `legion`，主机名 `nixos`。

- `configuration.nix`   NixOS 系统入口：导入全部 `system/` 模块、用户 `lilei`、DATATB 自动挂载（ntfs3 automount）、`environment.localBinInPath`
- `hardware-configuration.nix`  `nixos-generate-config` 生成（Btrfs 子卷布局），勿手动修改
- `home.nix`            Home Manager 入口：导入 `home/` 各模块、niri 手写 KDL 配置（`home/niri/`）、fcitx5 覆盖
- `packages.nix`        用户级软件包清单（浏览器 / 办公 / 通讯 / 笔记等）

详细说明见根目录 `README.md`「四」第 2 / 3 / 23 / 24 节。
