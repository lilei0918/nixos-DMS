_: {
  ################################
  # Tailscale：远程（办公室）访问家庭 NixOS 服务
  ################################
  # 家里宽带多无公网 IPv4（CGNAT），Tailscale 打洞/中继，无需端口映射。
  # 一次性初始化（交互式登录，配置写入 /var/lib/tailscale，重启保留）：
  #   sudo tailscale up
  # 在 Tailscale 管理后台开启 MagicDNS + HTTPS Certificates 后，为 Immich 提供 HTTPS：
  #   sudo tailscale serve --bg --https=443 http://localhost:2283
  # 办公室设备用同一账号登录，访问 https://<主机名>.<tailnet>.ts.net
  # 如需无人值守登录：在 secrets 里加 tailscale_auth_key，并设 services.tailscale.authKeyFile。

  services.tailscale.enable = true;

  # 尾网接口加入防火墙信任区（serve 的本地代理 + 经尾网直连服务均放行）
  networking.firewall.trustedInterfaces = ["tailscale0"];
}
