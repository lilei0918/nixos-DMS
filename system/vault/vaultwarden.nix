{
  config,
  pkgs,
  ...
}: let
  # 本地 TLS 证书（Vaultwarden 强制 HTTPS）
  # Bitwarden 新版 web vault 拒绝所有 http:// 请求（含 localhost），
  # 因此构建期生成自签证书，并加入系统信任，浏览器零警告访问 https://localhost:8080
  vaultwardenTls = pkgs.runCommand "vaultwarden-tls" {} ''
    mkdir -p $out
    cd $out

    # 本地 CA
    ${pkgs.openssl}/bin/openssl req -x509 -newkey rsa:4096 -nodes \
      -keyout ca.key -out ca.crt -days 3650 \
      -subj "/CN=Vaultwarden Local CA"

    # 服务器证书（含 localhost SAN）
    ${pkgs.openssl}/bin/openssl req -newkey rsa:2048 -nodes \
      -keyout server.key -out server.csr -subj "/CN=localhost"

    ${pkgs.openssl}/bin/openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key \
      -CAcreateserial -out server.crt -days 3650 \
      -extfile <(printf "subjectAltName=DNS:localhost,IP:127.0.0.1")

    chmod 644 ca.crt server.crt
    chmod 600 server.key
  '';
in {
  ############################################
  # Podman
  ############################################

  virtualisation.podman = {
    enable = true;

    dockerCompat = false;

    # 允许普通用户使用 podman
    defaultNetwork.settings.dns_enabled = false;
  };

  # podman-auto-update timer（配合容器 AutoUpdate=registry）
  # NixOS 24.11/25.05 的 virtualisation.podman 模块暂无 autoUpdate option，
  # 但 podman 包自带 .service/.timer 单元（已通过 systemd.packages 加载），
  # 只需用 wantedBy 启用 timer
  systemd.timers.podman-auto-update.wantedBy = ["timers.target"];

  # 信任本地 CA（Chrome / Firefox 系统根）
  security.pki.certificateFiles = [
    "${vaultwardenTls}/ca.crt"
  ];

  ############################################
  # Vaultwarden 容器（Quadlet）
  ############################################

  environment.etc."containers/systemd/vaultwarden.container".text = ''
    [Unit]
    Description=Vaultwarden password manager
    After=network-online.target
    Wants=network-online.target

    [Container]
    # SQLite 数据库持久化到宿主机
    Volume=/var/lib/vaultwarden:/data
    # TLS 证书（只读挂载）
    Volume=${vaultwardenTls}:/tls:ro
    # 仅本机访问（容器内 TLS 监听 80，宿主 8080 转发）
    PublishPort=127.0.0.1:8080:80
    Environment=DOMAIN=https://localhost:8080
    Environment=ROCKET_PORT=80
    Environment=ROCKET_TLS={certs="/tls/server.crt",key="/tls/server.key"}
    # 注册完成后已关闭（需注册时改回 true 并重建）
    Environment=SIGNUPS_ALLOWED=false
    Environment=WEBSOCKET_ENABLED=true

    # 注：Vaultwarden 新版已移除内置备份（BACKUP_* 变量无效，会被忽略），
    # 数据库在线备份由 system/vault/vaultwarden-backup.nix 的 systemd 服务负责
    EnvironmentFile=${config.sops.templates."vaultwarden-env".path}
    Image=docker.io/vaultwarden/server:latest
    AutoUpdate=registry

    [Service]
    Restart=on-failure
    RestartSec=5
    # 给容器足够时间优雅关闭（SQLite WAL checkpoint）
    # 全局 DefaultTimeoutStopSec=10s 可能不够
    TimeoutStopSec=60

    [Install]
    WantedBy=default.target
  '';

  ############################################
  # Vaultwarden 数据目录（SQLite）
  ############################################

  systemd.tmpfiles.rules = [
    "d /var/lib/vaultwarden 0755 root root - -"
  ];

  ############################################
  # Vaultwarden 管理后台 Token（sops 加密）
  ############################################

  sops.templates."vaultwarden-env" = {
    content = ''
      ADMIN_TOKEN=${config.sops.placeholder."vaultwarden_admin_token"}
    '';
  };

  # vaultwarden_admin_token 已在 system/secrets.nix 中统一定义

  ############################################
  # 额外工具
  ############################################

  environment.systemPackages = with pkgs; [
    podman
    podman-compose
  ];
}
