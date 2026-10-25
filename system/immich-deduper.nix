{
  pkgs,
  lib,
  ...
}: let
  ################################
  # Immich Deduper：重复/相似照片清理（按需启动，不常驻）
  ################################
  # 上游：https://github.com/RazgrizHsu/immich-deduper （GPLv3，仅提供容器镜像）
  #
  # 设计要点：
  #   1. 不随系统启动：`wantedBy = []`，只在手动 `systemctl start immich-deduper` 时运行。
  #   2. rootful podman（不是 rootless）：/srv/immich 是 0700 immich:immich，
  #      rootless 读不到缩略图。
  #   3. 容器以 immich 的 uid:gid 运行 → PostgreSQL `local all all peer` 把它认作
  #      role immich，**不需要给 immich 角色设密码、也不暴露 5432**。
  #   4. 媒体目录用「与宿主机相同」的路径挂载（/srv/immich:/srv/immich:ro）：
  #      podman 不创建 /.dockerenv，Deduper 的 IS_DOCKER=false，不会重映射成 /immich。
  #   5. UI 只发布到 127.0.0.1:8086，不进防火墙、不暴露到局域网。
  #   6. 删除动作只把 `asset.status` 改成 trashed → 进 Immich 回收站，可恢复。
  #
  # 使用（详见 MEMO「三」/ README「System」）：
  #   sudo systemctl start immich-deduper     # 首次会拉镜像（约 2 GB）
  #   xdg-open http://127.0.0.1:8086
  #   sudo systemctl stop immich-deduper      # 用完即停
  #   sudo journalctl -u immich-deduper -f    # 看日志
  #
  # 升级：改下面的 image 标签（上游 tag 形如 0.3.5 / 0.3.5-cuda），或临时
  #   `sudo podman pull docker.io/razgrizhsu/immich-deduper:latest-cpu` 后手动 run。
  ################################
  port = 8086;
  dataDir = "/var/lib/immich-deduper";

  # CPU 镜像（AMD 核显不支持；上游只有 NVIDIA CUDA 变体）
  image = "docker.io/razgrizhsu/immich-deduper:0.3.5";
  qdrantImage = "docker.io/qdrant/qdrant:v1.17.1";

  container = "immich-deduper";
  qdrantContainer = "immich-deduper-qdrant";
  network = "immich-deduper";

  podman = lib.getExe pkgs.podman;

  # 启动：Qdrant 后台常驻在单元生命周期内，Deduper 前台运行（systemd 直接托管）
  startScript = pkgs.writeShellScript "immich-deduper-start" ''
    set -euo pipefail

    ${podman} network exists ${network} >/dev/null 2>&1 || ${podman} network create ${network}

    # Qdrant（向量库）：容器内以 uid 1000 运行，数据目录由 tmpfiles 预先 chown
    ${podman} rm -f ${qdrantContainer} >/dev/null 2>&1 || true
    ${podman} run -d --name ${qdrantContainer} --network ${network} \
      -v ${dataDir}/qdrant:/qdrant/storage \
      ${qdrantImage} >/dev/null

    # Deduper：以 immich uid 运行以走 peer 认证；--rm + 前台，systemd 停单元即停容器
    ${podman} rm -f ${container} >/dev/null 2>&1 || true
    exec ${podman} run --rm --name ${container} --network ${network} \
      -p 127.0.0.1:${toString port}:${toString port} \
      --user "$(id -u immich):$(id -g immich)" \
      -e HOME=/app/data/home \
      -e TORCH_HOME=/app/data/home/.cache/torch \
      -e PSQL_HOST=/run/postgresql \
      -e PSQL_PORT=5432 \
      -e PSQL_DB=immich \
      -e PSQL_USER=immich \
      -e PSQL_PASS= \
      -e IMMICH_PATH=/srv/immich \
      -e QDRANT_URL=http://${qdrantContainer}:6333 \
      -e QDRANT_COLL=deduper \
      -e DEDUP_PORT=${toString port} \
      -v ${dataDir}/data:/app/data \
      -v /srv/immich:/srv/immich:ro \
      -v /run/postgresql:/run/postgresql:ro \
      ${image}
  '';

  # 停止后清理容器与网络（数据目录保留，向量与缓存下次不用重算）
  stopScript = pkgs.writeShellScript "immich-deduper-stop" ''
    ${podman} rm -f ${container} ${qdrantContainer} >/dev/null 2>&1 || true
    ${podman} network rm ${network} >/dev/null 2>&1 || true
  '';
in {
  systemd.services.immich-deduper = {
    description = "Immich Deduper (on-demand duplicate finder, not started at boot)";

    # 关键：不加入任何 target，避免开机自启
    wantedBy = [];

    after = ["network-online.target" "postgresql.service" "immich-server.service"];
    wants = ["network-online.target"];
    requires = ["immich-server.service" "postgresql.service"];

    unitConfig.RequiresMountsFor = "/srv/immich";

    serviceConfig = {
      ExecStart = startScript;
      ExecStopPost = stopScript;
      Restart = "no";
      # 首次启动要拉约 2 GB 镜像，不能按默认 90s 超时
      TimeoutStartSec = 0;
      TimeoutStopSec = 60;
      # podman 需要在主进程与容器之间转发信号
      KillMode = "mixed";
    };
  };

  # 数据目录：
  #   data/   Deduper 的 SQLite、向量缓存、日志（属主 immich；组 users(100) 便于
  #           lilei 读日志，写权限仍只有 immich）
  #   qdrant/ Qdrant 存储（官方镜像以 uid 1000 运行）
  systemd.tmpfiles.rules = [
    "d ${dataDir} 0750 root root -"
    "d ${dataDir}/data 0750 immich users -"
    "d ${dataDir}/data/home 0750 immich users -"
    "d ${dataDir}/data/cache 0750 immich users -"
    "d ${dataDir}/qdrant 0750 1000 1000 -"
  ];
}
