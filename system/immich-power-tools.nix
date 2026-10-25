{
  pkgs,
  lib,
  ...
}: let
  ################################
  # Immich Power Tools：批量整理 Immich 的 Web UI（按需启动）
  ################################
  # 上游：https://github.com/immich-power-tools/immich-power-tools （非官方客户端）
  # 功能：批量改人物、合并人物、缺失位置、潜在相册、统计、Smart Search、批量日期偏移。
  #
  # 设计要点：
  #   1. 按需启动，不随系统启动（wantedBy = []）。
  #   2. 直连 Immich 的 PostgreSQL 读数据 + 调 Immich HTTP API 写数据：
  #      - DB 走 unix socket + peer 认证（容器以 immich uid 运行），不暴露 5432、不设密码；
  #      - API 走 http://127.0.0.1:2283（--network host，仅本机）。
  #   3. 只监听 127.0.0.1:8001（HOSTNAME=127.0.0.1 + PORT=8001），不暴露局域网。
  #   4. 密钥不落仓库：运行时读取 /var/lib/immich-power-tools/power-tools.env（root 0600）。
  #
  # 首次使用（详见 MEMO「十四」）：
  #   sudo systemctl start immich-power-tools        # 首次会拉镜像
  #   # 若提示缺少 IMMICH_API_KEY：去 Immich 网页「账户设置 → API 密钥」新建一个
  #   # （勾选全部权限），写入 /var/lib/immich-power-tools/power-tools.env
  #   sudo systemctl start immich-power-tools
  #   浏览器打开 http://127.0.0.1:8001 （用 Immich 的邮箱/密码登录）
  #
  # 升级：改下面 image 的 tag（上游 tag 形如 0.25.0），再 rebuild。
  ################################
  port = 8001;
  dataDir = "/var/lib/immich-power-tools";
  envFile = "${dataDir}/power-tools.env";

  image = "ghcr.io/immich-power-tools/immich-power-tools:0.25.0";
  container = "immich-power-tools";

  podman = lib.getExe pkgs.podman;

  # 首次启动：目录就绪 + 生成 env 模板（含随机 JWT_SECRET）+ 校验 API Key
  preStart = pkgs.writeShellScript "immich-power-tools-pre" ''
    set -euo pipefail
    install -d -m 0750 ${dataDir} ${dataDir}/data ${dataDir}/cache
    chown -R "$(id -u immich):$(id -g immich)" ${dataDir}/data ${dataDir}/cache

    if [ ! -f ${envFile} ]; then
      umask 077
      {
        echo "IMMICH_URL=http://127.0.0.1:2283"
        echo "IMMICH_API_KEY="
        echo "JWT_SECRET=$(${lib.getExe pkgs.openssl} rand -hex 32)"
        echo "SECURE_COOKIE=false"
        echo "POWER_TOOLS_ENDPOINT_URL=http://127.0.0.1:${toString port}"
        echo "# 可选：Smart Search 需要 OpenAI 兼容接口"
        echo "#AI_API_KEY="
        echo "#AI_BASE_URL=https://api.openai.com/v1"
        echo "#AI_MODEL=gpt-4o-mini"
      } > ${envFile}
      chmod 600 ${envFile}
    fi

    if ! grep -qE '^IMMICH_API_KEY=.+' ${envFile}; then
      echo "ERROR: ${envFile} 里 IMMICH_API_KEY 为空。" >&2
      echo "  1) 打开 Immich → 账户设置 → API 密钥 → 新建（勾选全部权限）" >&2
      echo "  2) sudoedit ${envFile}，把 key 填到 IMMICH_API_KEY=" >&2
      echo "  3) sudo systemctl start immich-power-tools" >&2
      exit 1
    fi
  '';

  startScript = pkgs.writeShellScript "immich-power-tools-start" ''
    set -euo pipefail
    ${podman} rm -f ${container} >/dev/null 2>&1 || true
    exec ${podman} run --rm --name ${container} --network host \
      --user "$(id -u immich):$(id -g immich)" \
      --env-file ${envFile} \
      -e HOSTNAME=127.0.0.1 \
      -e PORT=${toString port} \
      -e APP_DB_PATH=/app/data/app.db \
      -e HOME=/app/data \
      -e DATABASE_URL="postgresql:///immich?host=/run/postgresql" \
      -v ${dataDir}/data:/app/data \
      -v ${dataDir}/cache:/app/.next/cache \
      -v /run/postgresql:/run/postgresql:ro \
      ${image}
  '';

  stopScript = pkgs.writeShellScript "immich-power-tools-stop" ''
    ${podman} rm -f ${container} >/dev/null 2>&1 || true
  '';
in {
  systemd.services.immich-power-tools = {
    description = "Immich Power Tools (on-demand bulk organizer web UI)";

    # 不常驻：需要时 `systemctl start`；想开机自启就把 wantedBy 改成 ["multi-user.target"]
    wantedBy = [];

    after = ["network-online.target" "postgresql.service" "immich-server.service"];
    wants = ["network-online.target"];
    requires = ["immich-server.service" "postgresql.service"];

    serviceConfig = {
      ExecStartPre = preStart;
      ExecStart = startScript;
      ExecStopPost = stopScript;
      Restart = "no";
      # 首次拉镜像可能较慢
      TimeoutStartSec = 0;
      TimeoutStopSec = 60;
      KillMode = "mixed";
    };
  };

  systemd.tmpfiles.rules = [
    "d ${dataDir} 0750 root root -"
    "d ${dataDir}/data 0750 immich users -"
    "d ${dataDir}/cache 0750 immich users -"
  ];
}
