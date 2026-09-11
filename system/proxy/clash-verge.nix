# =============================================================================
# 主用方案：Clash Verge Rev（nixpkgs 官方模块 programs.clash-verge）
# =============================================================================
# 使用方式（Niri + Wayland）：
#   1. 启用后首次打开 clash-verge（GUI，super+d / 应用菜单）
#   2. 「订阅 → 新建 → 粘贴订阅 URL → 更新」，选中一个 profile
#   3. 打开「系统代理」或 Tun 模式即可全局代理
#
# 实例模型：serviceMode + autoStart 同时开启。
#   - clash-verge-service 由 systemd 开机常驻（TUN 所需的特权核心）
#   - GUI（autoStart）开机自启，需在 GUI 里开启「服务模式」以复用 service 核心
#   - 若 GUI 未开「服务模式」，它会再起一个自己的核心 → 出现"两个 clash"。
#     因此务必在 GUI：设置 → 开启「服务模式」+「Tun 模式」。
#
# 模块行为（见本仓库锁定的 nixpkgs nixos/modules/programs/clash-verge.nix）：
#   - tunMode：生成 security.wrappers.clash-verge，授予
#     cap_net_bind_service / cap_net_raw / cap_net_admin（TUN + DNS 所需），
#     并把 firewall.checkReversePath 默认设为 "loose"（我们 network.nix 已是 loose）
#   - serviceMode：systemd 服务 clash-verge-service（clash 核心以 service 常驻）
#   - autoStart：生成 XDG autostart 条目（本会话经 xdg-autostart-generator 生效）
#
# 注意：
#   - 与 daed（system/proxy/daed.nix）、mihomo（system/proxy/mihomo.nix）
#     互斥，切换方法见 hosts/legion/configuration.nix 的 proxy import 注释。
#   - Wayland 下若 GUI 渲染异常属 Clash Verge Rev 已知问题，核心不受影响。
# =============================================================================
_: {
  programs.clash-verge = {
    enable = true;

    # 特权服务常驻（TUN 依赖；GUI 需开启「服务模式」复用此核心）
    serviceMode = true;

    # 授予 TUN / DNS 所需 capabilities，并把 reverse-path 检查放松为 loose
    tunMode = true;

    # 桌面登录自动启动 GUI（唯一的 clash 实例）
    autoStart = true;

    # 默认 "users"：本机用户均能访问 service socket
    # 更严格可改成仅含 lilei 的专用组
    # group = "users";
  };
}
