{
  config,
  pkgs,
  ...
}: {
  services.mihomo = {
    enable = true;
    # 保持读取你的配置文件
    configFile = "/home/lilei/.config/mihomo/config.yaml";
    tunMode = true;
    webui = pkgs.metacubexd;
  };

  # 移除之前自定义的 User/Group 和 ReadWritePaths，恢复系统默认的高权限沙箱以完美支持 TUN
  systemd.services.mihomo = {
    path = [pkgs.mihomo];
  };

  # 防火墙放行（TUN 接口 "Meta" 已在 system/network.nix 的 trustedInterfaces 中配置）
  networking.firewall = {
    checkReversePath = "loose";
    allowedTCPPorts = [9090 7890 7891]; # 放行控制面板及代理端口
  };
}
