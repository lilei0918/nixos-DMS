# =============================================================================
# 主用方案：Clash Verge Rev（nixpkgs 官方模块 programs.clash-verge）
# =============================================================================
# 使用方式（Niri + Wayland）：
#   1. 启用后首次打开 clash-verge（GUI，super+d / 应用菜单）
#   2. 「订阅 → 新建 → 粘贴订阅 URL → 更新」，选中一个 profile
#   3. 打开「系统代理」或 Tun 模式即可全局代理
#
# 实例模型：只随 GUI 运行一个 clash（autoStart 开机拉起 GUI，核心由 GUI 管理）。
# ⚠️ 不要把 serviceMode 与 autoStart 同时开 true：否则开机 = GUI 一个核心
#    + clash-verge-service 又一个核心，变成两个 clash。若想要无头常驻
#    （不开 GUI、开机即按上次 profile 代理），再改 serviceMode=true + autoStart=false。
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

    # 只随 GUI 单实例运行（见上方"实例模型"说明）
    serviceMode = false;

    # 授予 TUN / DNS 所需 capabilities，并把 reverse-path 检查放松为 loose
    tunMode = true;

    # 桌面登录自动启动 GUI（唯一的 clash 实例）
    autoStart = true;

    # 默认 "users"：本机用户均能访问 service socket
    # 更严格可改成仅含 lilei 的专用组
    # group = "users";
  };
}
