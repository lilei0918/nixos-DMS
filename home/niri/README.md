# home/niri

Niri 窗口管理器配置（**手写 KDL**，参照 ryan4yin/nix-config 风格）。

## 架构

- `kdl.nix`    Home Manager 模块：把 `conf/` 下的 KDL 文件链接到 `~/.config/niri/`
- `conf/config.kdl`            主配置：input / 输出 / layout / environment / 命名工作区，顶部 `include` 分片
- `conf/keybindings.kdl`       快捷键（`super+return` alacritty、`super+d` walker、niri 内置截图 `Print` 等）
- `conf/windowrules.kdl`       窗口规则：圆角 10/10/5/5、工作区分派、浮动类（QQ / telegram / hermes...）、SiYuan 独占 note 列
- `conf/spawn-at-startup.kdl`  自启动：polkit、fcitx5、blueman-applet、延迟 QQ

## 动态配色（DMS）

`config.kdl` 用 `include optional=true` 引入 DMS 生成的 `dms/*.kdl`（`~/.config/niri/dms/`）：
- `dms/colors.kdl` 提供焦点环 / 边框颜色（DMS 换壁纸 → matugen 重新生成 → niri 热重载，焦点环随壁纸变色）
- `dms/layout.kdl`、`dms/outputs.kdl` 等由 DMS 接管布局与输出
- `optional=true`：DMS 未生成时 niri 仍可启动（文件缺失仅告警）

## 版本

niri 使用 nixpkgs 自带的 `pkgs.niri`（`system/niri.nix` 的 `programs.niri`），跟随 nixpkgs unstable 滚动更新。
`include` 语法需要 niri ≥ v25.11（nixpkgs unstable 已是 26.04，满足）。

> 注意：`open-on-workspace` 必须先声明工作区（`config.kdl` 里 `workspace` 节点）。
