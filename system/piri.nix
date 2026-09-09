# =============================================================================
# Piri：Niri 扩展（Rust daemon，Unix Socket IPC）
# =============================================================================
# 与 DMS 分工：DMS 管桌面 Shell/状态栏，Piri 管窗口/工作区自动化。
# 配置在 ~/.config/niri/piri.toml（仓库 home/niri/conf/piri.toml，kdl.nix
# out-of-store symlink 热加载，改动即时生效）。
# 三件套：scratchpads（super+t 下拉终端）/ singleton（super+b 聚焦或启动）
#         / window_rule（zed、codium 归位 code 工作区）。
# 其余插件（empty/mark/sticky/window_order/swallow/workspace_rule）默认关闭，
# 需要时在 piri.toml 的 [piri.plugins] 打开并补配置即可。
# =============================================================================
{inputs, ...}: {
  imports = [
    inputs.piri.nixosModules.piri
  ];

  # 官方模块：装 piri 包 + systemd user 服务（graphical-session.target 启动 daemon）
  services.piri = {
    enable = true;
  };
}
