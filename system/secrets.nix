{config, ...}: {
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;

    age = {
      keyFile = "/etc/sops/age/keys.txt";
    };

    secrets = {
      vaultwarden_admin_token = {};

      # 用户密码 hash（neededForUsers：activation 阶段解密，先于用户创建）
      password_hash = {
        neededForUsers = true;
      };

      # Vaultwarden 本地 TLS 证书私钥/证书
      # 重装机器：只需放置 age key，sops 自动解密写入，无需手动生成
      vaultwarden_tls_ca_key = {
        path = "/var/lib/vaultwarden/tls/ca.key";
      };

      vaultwarden_tls_ca_crt = {
        path = "/var/lib/vaultwarden/tls/ca.crt";
      };

      vaultwarden_tls_server_key = {
        path = "/var/lib/vaultwarden/tls/server.key";
      };

      vaultwarden_tls_server_crt = {
        path = "/var/lib/vaultwarden/tls/server.crt";
      };

      # Aoying Radar 只读账户 API（持仓/止损监控）
      binance_api_key = {};

      binance_api_secret = {};
    };

    # Aoying Radar 服务环境文件：systemd user service 通过 EnvironmentFile 读取，
    # 只读权限 + IP 白名单的 Key，程序仅调用只读接口。
    templates."aoying-radar-env" = {
      content = ''
        BINANCE_API_KEY=${config.sops.placeholder.binance_api_key}
        BINANCE_API_SECRET=${config.sops.placeholder.binance_api_secret}
      '';
      path = "/run/secrets/aoying-radar-env";
      mode = "0444";
      owner = "lilei";
      group = "users";
    };
  };
}
