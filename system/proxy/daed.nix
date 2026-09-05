# =============================================================================
# 主用方案：daed = dae (eBPF 透明代理) + Web 管理面板
# =============================================================================
# daed 使用方式：
#   1. 首次启用后访问 http://127.0.0.1:2023
#   2. 初始化时配置：tproxy_port 填 12345（仅本机透明代理用，不对外放行防火墙）
#   3. 在面板中添加订阅 URL、配置 group / routing，点运行即可
#
# 注意：daed 与 mihomo（system/proxy/mihomo.nix）不能同时开启。
# 切回 mihomo 的方法见 mihomo.nix 顶部注释。
# =============================================================================
{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.daeuniverse.nixosModules.daed
  ];

  services.daed = {
    enable = true;

    # 默认选项如下，按需覆盖
    # package = inputs.daeuniverse.packages.x86_64-linux.daed;
    # configDir = "/etc/daed";
    # listen = "127.0.0.1:2023";

    # 使用 Loyalsoldier 增强版规则库（包含 gfw / google / category-ai-!cn 等分类）。
    # 默认的 v2ray-domain-list-community 没有 gfw 分类，会报
    # "code gfw not found in geosite.dat"。
    assetsPaths = [
      "${pkgs.v2ray-rules-dat}/share/v2ray/geoip.dat"
      "${pkgs.v2ray-rules-dat}/share/v2ray/geosite.dat"
    ];

    # tproxy 端口仅供本机 eBPF 透明代理，无需对局域网开放。
    # 上游模块默认 openFirewall.enable=true 会把 TCP/UDP 12345 放行到全网，
    # 属多余暴露面，显式关闭（仅当确要当局域网代理网关时才改回 true）。
    openFirewall = {
      enable = false;
      port = 12345; # 与面板 tproxy_port 保持一致，供文档/排查核对
    };
  };

  # dae 需要地理数据库资产（v2ray-geoip / v2ray-domain-list-community），
  # daed 模块默认会链接到 configDir，无需额外配置。

  ############################################
  # garnix 二进制缓存（daeuniverse/flake.nix 的构建产物）
  # 注意：garnix 时常 503 挂掉，每次 rebuild 会重试 5 次拖慢构建，已禁用。
  # 需要更新 daed/dae 时再临时启用，或本地编译。
  ############################################
  # nix.settings = {
  #   substituters = [
  #     "https://cache.garnix.io"
  #   ];
  #   trusted-public-keys = [
  #     "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
  #   ];
  # };

  ############################################
  # 防火墙
  ############################################
  # dae 用 TPROXY 分流，回程流量需要放行，保持宽松的 reverse-path 检查
  networking.firewall = {
    checkReversePath = "loose";
  };
}
