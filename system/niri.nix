{pkgs, ...}: {
  # niri 使用 nixpkgs 自带的 programs.niri 模块（pkgs.niri，跟随 nixpkgs unstable，
  # 当前 26.04，已含 include 支持）。替代原先的 niri-flake（niri-stable 25.08 无 include）。
  #
  # 模块自动处理：
  #   - 安装 niri 包（niri-session 进系统 PATH，greetd 的 --cmd niri-session 可用）
  #   - 注册 systemd units（niri.service，含 PATH 修正）
  #   - xdg portal 默认配置（与 system/xdg.nix 合并，xdg.nix 的显式设置优先）
  #   - nautilus 用于 portal FileChooser（useNautilus 默认 true）
  #
  # 配置文件为手写 KDL：home/niri/conf/*.kdl（Home Manager 链接），
  # 主 config.kdl 用 include 引入 dms/*.kdl 实现随壁纸动态配色。
  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };
}
