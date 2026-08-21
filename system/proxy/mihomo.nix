# =============================================================================
# 备用方案：mihomo (Clash Meta)
# =============================================================================
# 当前主用方案是 daed（见 system/proxy/daed.nix）。
# 若要切回 mihomo：
#   1. 在 hosts/legion/configuration.nix 中注释 daed.nix 的 import，改 import 本文件
#   2. sudo nixos-rebuild switch
#   3. 订阅链接在 /home/lilei/.config/mihomo/config.yaml 第 17 行 url 修改
#
# daed 与 mihomo 不能同时开启（都会抢 TUN/TPROXY 和防火墙规则）。
# =============================================================================
{
  pkgs,
  myvars,
  ...
}: {
  services.mihomo = {
    enable = true;
    # 保持读取你的配置文件
    configFile = "${myvars.homeDirectory}/.config/mihomo/config.yaml";
    tunMode = true;
    webui = pkgs.metacubexd;
  };

  # 移除之前自定义的 User/Group 和 ReadWritePaths，恢复系统默认的高权限沙箱以完美支持 TUN
  systemd.services.mihomo = {
    path = [pkgs.mihomo];
  };

  # 防火墙放行（TUN 接口 "Meta" 需在 trustedInterfaces 中配置）
  networking.firewall = {
    checkReversePath = "loose";
    trustedInterfaces = [
      "Meta"
    ];
    allowedTCPPorts = [
      9090
      7890
      7891
    ]; # 放行控制面板及代理端口
  };
}
