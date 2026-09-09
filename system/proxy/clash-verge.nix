# =============================================================================
# 主用方案：Clash Verge Rev（nixpkgs 官方模块 programs.clash-verge）
# =============================================================================
# 使用方式（Niri + Wayland）：
#   1. 启用后首次打开 clash-verge（GUI，super+d / 应用菜单）
#   2. 「订阅 → 新建 → 粘贴订阅 URL → 更新」，选中一个 profile
#   3. 打开「系统代理」或 Tun 模式即可全局代理
#
# 模块行为（见本仓库锁定的 nixpkgs nixos/modules/programs/clash-verge.nix）：
#   - tunMode：生成 security.wrappers.clash-verge，授予
#     cap_net_bind_service / cap_net_raw / cap_net_admin（TUN + DNS 所需），
#     并把 firewall.checkReversePath 默认设为 "loose"（我们 network.nix 已是 loose）
#   - serviceMode：systemd 服务 clash-verge-service（clash 核心以 service 常驻，
#     组权限按 group 控制）
#   - autoStart：生成 XDG autostart 条目（本会话经 xdg-autostart-generator 生效）
#
# 注意：
#   - 与 daed（system/proxy/daed.nix）、mihomo（system/proxy/mihomo.nix）
#     互斥，切换方法见 hosts/legion/configuration.nix 的 proxy import 注释。
#   - Wayland 下若 GUI 渲染异常属 Clash Verge Rev 已知问题，核心服务不受影响。
# =============================================================================
_: {
  programs.clash-verge = {
    enable = true;

    # clash 核心以系统服务运行（TUN 提权所需）
    serviceMode = true;

    # 授予 TUN / DNS 所需 capabilities，并把 reverse-path 检查放松为 loose
    tunMode = true;

    # 桌面登录自动启动 GUI（不需要弹窗可改 false，服务与 TUN 不受影响）
    autoStart = true;

    # 默认 "users"：本机用户均能访问 service socket
    # 更严格可改成仅含 lilei 的专用组
    # group = "users";
  };
}
