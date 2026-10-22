{
  config,
  pkgs,
  ...
}: {
  ############################################
  # Immich 备份（数据库 + 媒体库）
  # 新版 Immich 无内置备份，必须自己备：
  #   1. 数据库：pg_dumpall 在线导出 → /srv/immich/backups/db/（nvme0n1，与 DB 所在
  #      nvme1n1 异盘，抗单盘损坏），gzip 压缩，保留 KEEP_DAYS 天
  #   2. 媒体：只镜像原图/头像（upload/ library/ profile/）→ DATATB
  #      （nvme1n1，与媒体所在 nvme0n1 异盘）；thumbs/ encoded-video 可再生成，不备
  # 交叉落盘：任一块盘损坏都能恢复；整机故障仍需定期外导（U 盘）兜底
  # ⚠️ 升级 Immich 前先跑一次备份（数据库迁移单向不可逆）；恢复须用相同/更新版本
  ############################################
  systemd.services.immich-backup = {
    description = "Backup Immich database (pg_dumpall) + media library (cross-disk mirror)";

    after = ["postgresql.service"];

    # 媒体库挂载点必须先就绪（否则会把数据写到根盘的同名空目录）
    unitConfig.RequiresMountsFor = ["/srv/immich"];

    path = with pkgs; [
      config.services.postgresql.package # pg_dumpall（与服务器同版本）
      gzip
      rsync
      util-linux # runuser / mountpoint
      coreutils
      findutils
    ];

    serviceConfig = {
      Type = "oneshot";
      TimeoutStopSec = 0;
    };

    script = ''
      set -euo pipefail

      MEDIA=/srv/immich
      DBDUMP_DIR="$MEDIA/backups/db"
      KEEP_DAYS=14
      DATATB=/run/media/lilei/DATATB
      DATATB_ROOT="$DATATB/immich-backup"

      if ! mountpoint -q "$MEDIA"; then
        echo "$MEDIA not mounted, skip"
        exit 0
      fi

      mkdir -p "$DBDUMP_DIR"

      # 1. 数据库在线导出（以 postgres 用户，peer 认证）
      TS=$(date +%Y%m%d-%H%M%S)
      OUT="$DBDUMP_DIR/immich-db-$TS.sql.gz"
      runuser -u postgres -- pg_dumpall --clean --if-exists | gzip -c > "$OUT"

      if [ ! -s "$OUT" ] || ! gzip -t "$OUT" 2>/dev/null; then
        echo "DB dump failed or corrupted, removing $OUT"
        rm -f "$OUT"
        exit 1
      fi
      chmod 600 "$OUT"
      echo "created $OUT ($(du -h "$OUT" | cut -f1))"

      # 2. 本地保留最近 KEEP_DAYS 天
      find "$DBDUMP_DIR" -name 'immich-db-*.sql.gz' -mtime +$((KEEP_DAYS - 1)) -delete

      # 3. 镜像到 DATATB（异盘）
      if mountpoint -q "$DATATB"; then
        mkdir -p "$DATATB_ROOT/db" "$DATATB_ROOT/media"

        # 数据库 dump 第二份（nvme0n1 → nvme1n1）
        rsync -rt --no-perms --no-owner --no-group --delete \
          "$DBDUMP_DIR/" "$DATATB_ROOT/db/"

        # 媒体库原图/头像镜像（--delete 保持同步；NTFS 不支持 POSIX 权限故关掉 perms/owner）
        for d in upload library profile; do
          if [ -d "$MEDIA/$d" ]; then
            mkdir -p "$DATATB_ROOT/media/$d"
            rsync -rt --no-perms --no-owner --no-group --delete \
              "$MEDIA/$d/" "$DATATB_ROOT/media/$d/"
          fi
        done

        echo "mirrored db + media to $DATATB_ROOT"
      else
        echo "DATATB not mounted, skip mirror"
      fi
    '';
  };

  systemd.timers.immich-backup = {
    description = "Daily backup of Immich (db + media)";

    wantedBy = ["timers.target"];

    timerConfig = {
      OnCalendar = "*-*-* 04:30:00";
      Persistent = true; # 关机错过 → 开机补跑
      RandomizedDelaySec = "10min";
    };
  };
}
