###更新订阅链接
##！1.
#vim ~/.config/mihomo/config.yaml        # 第 17 行 url
# 2. 重启服务
#systemctl restart mihomo
# 3. 验证
#curl http://127.0.0.1:9090/providers/proxies   # 看 mysub 是否更新
{pkgs, ...}: {
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
    allowedTCPPorts = [
      9090
      7890
      7891
    ]; # 放行控制面板及代理端口
  };
}
