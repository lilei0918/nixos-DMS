{pkgs, ...}: {
  ############################################
  # Vaultwarden 数据库在线备份（本地 + DATATB 镜像 + 加密盘归档）
  # 历史：曾把备份 rsync 到 Arch btrfs 分区（UUID 9dccd22a-…，README 记为 nvme0n1p7），
  #       Arch 已于 2026-09 删除，异盘同步段移除后改镜像到本机数据盘 DATATB。
  # 现在的备份：
  #   1. 本地：sqlite3 .backup → /var/lib/vaultwarden/backups/（保留 7 天）
  #   2. DATATB（镜像）：rsync --delete → /run/media/lilei/DATATB/vaultwarden-backup/
  #      （与本地同滚动 7 天；DATATB 为 ntfs3 自动挂载的数据盘）
  #   3. 加密盘（按需，长期归档）：vault 已解锁挂载才 rsync（只增不删）到
  #      /mnt/vault/vaultwarden/backups/；未解锁跳过并留日志
  # 注：本地、DATATB、加密盘分属 nvme1n1 的不同分区但同属一块物理盘，
  #     分区/文件系统级冗余有，异盘容灾仍没有；长期归档请定期外导
  #     （U 盘等离线介质）再保一份（习惯同 backup-credentials.sh）。
  # 注：Vaultwarden 新版已移除内置备份，故用 sqlite3 .backup 在线备份（WAL 安全）
  ############################################
  systemd.services.vaultwarden-backup = {
    description = "Backup Vaultwarden db (local + DATATB mirror + vault archive)";

    after = ["vaultwarden.service"];

    path = with pkgs; [
      sqlite # sqlite3 在线备份 + integrity_check
      rsync # 同步到 DATATB / 加密盘
      util-linux # mountpoint：检测 DATATB / vault 是否挂载
      coreutils
      findutils
    ];

    serviceConfig = {
      Type = "oneshot";
      TimeoutStopSec = 0;
    };

    script = ''
      set -euo pipefail

      DB=/var/lib/vaultwarden/db.sqlite3
      BACKUP_DIR=/var/lib/vaultwarden/backups
      KEEP_DAYS=7

      # 等待 Vaultwarden 数据库就绪（最长 60 秒）
      for _ in $(seq 1 12); do
        if [ -f "$DB" ]; then
          break
        fi
        sleep 5
      done
      if [ ! -f "$DB" ]; then
        echo "vaultwarden db not found, skip"
        exit 0
      fi

      mkdir -p "$BACKUP_DIR"

      # SQLite 在线备份（WAL 模式下仍保持一致），无需停止容器
      OUT="$BACKUP_DIR/backup-$(date +%Y%m%d-%H%M%S).db"
      sqlite3 "$DB" ".backup '$OUT'"

      # 完整性校验：校验失败的文件不入库，直接删除并让本次备份报错
      CHECK=$(sqlite3 "$OUT" "PRAGMA integrity_check;")
      if [ "$CHECK" != "ok" ]; then
        echo "vaultwarden backup integrity check FAILED: $CHECK"
        rm -f "$OUT"
        exit 1
      fi
      echo "created $OUT (integrity check ok)"

      # 本地保留最近 KEEP_DAYS 天
      find "$BACKUP_DIR" -name 'backup-*.db' -mtime +$((KEEP_DAYS - 1)) -delete

      # DATATB 数据盘镜像（随本地 7 天滚动，--delete 保持同步）
      DATATB_MP=/run/media/lilei/DATATB
      DATATB_DEST="$DATATB_MP/vaultwarden-backup"
      if mountpoint -q "$DATATB_MP"; then
        mkdir -p "$DATATB_DEST"
        rsync -a --delete "$BACKUP_DIR/" "$DATATB_DEST/"
        echo "vaultwarden backups mirrored to $DATATB_DEST"
      else
        echo "DATATB not mounted, skip mirror"
      fi

      # 加密盘副本（按需，长期归档）：vault 已解锁挂载才同步
      if [ -b /dev/mapper/vault ] && mountpoint -q /mnt/vault; then
        VAULT_DEST=/mnt/vault/vaultwarden/backups
        mkdir -p "$VAULT_DEST"
        # 不删旧文件，加密盘内只增不删，作为长期归档
        rsync -a "$BACKUP_DIR/" "$VAULT_DEST/"
        echo "vaultwarden backups archived to $VAULT_DEST"
      else
        echo "encrypted vault not open, skip vault archive"
      fi
    '';
  };

  systemd.timers.vaultwarden-backup = {
    description = "Daily backup of Vaultwarden (local + DATATB mirror + vault archive)";

    wantedBy = ["timers.target"];

    timerConfig = {
      OnCalendar = "daily";
      Persistent = true; # 关机错过计划 → 开机后立即补跑
      RandomizedDelaySec = "5min";
    };
  };
}
