{
  config,
  pkgs,
  ...
}: {
  # 本地 TLS 证书（Vaultwarden 强制 HTTPS）
  # Bitwarden 新版 web vault 拒绝所有 http:// 请求（含 localhost）。
  # 私钥/证书用 sops 加密存于 secrets/secrets.yaml，boot 时 sops-nix 解密写入
  # /var/lib/vaultwarden/tls（容器在 sops-nix.service 之后启动）。
  # CA 公钥提交在仓库 certs/vaultwarden-ca.crt，构建期进入系统信任，浏览器零警告。
  # 重装机器：放置 age key → rebuild 即可，无需手动生成/复制证书。
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

  # 信任本地 CA（Chrome / Firefox 系统根），CA 公钥提交在仓库，构建期确定
  security.pki.certificateFiles = [
    ./certs/vaultwarden-ca.crt
  ];

  ############################################
  # Vaultwarden 容器（Quadlet）
  ############################################

  environment.etc."containers/systemd/vaultwarden.container".text = ''
    [Unit]
    Description=Vaultwarden password manager
    After=network-online.target
    Wants=network-online.target
    After=sops-nix.service
    Wants=sops-nix.service

    [Container]
    # SQLite 数据库持久化到宿主机
    Volume=/var/lib/vaultwarden:/data
    # TLS 证书（只读挂载，一次性生成于 /var/lib/vaultwarden/tls）
    Volume=/var/lib/vaultwarden/tls:/tls:ro
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
  # Vaultwarden 数据目录（SQLite + TLS）
  # 敏感数据（db.sqlite3、TLS 私钥），权限收紧为 0700 root
  ############################################

  systemd.tmpfiles.rules = [
    "d /var/lib/vaultwarden 0700 root root - -"
    "d /var/lib/vaultwarden/tls 0700 root root - -"
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
