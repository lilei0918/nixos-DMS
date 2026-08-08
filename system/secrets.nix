{
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;

    age = {
      keyFile = "/etc/sops/age/keys.txt";
    };

    secrets = {
      deepseek_api_key = {};

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
    };
  };
}
