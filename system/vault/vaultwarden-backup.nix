{pkgs, ...}: {
  ############################################
  # Vaultwarden 数据库在线备份 + 同步到 Arch 盘
  # Arch btrfs 分区：nvme1n1p7 (UUID 9dccd22a-c64e-494b-ab1a-e226b843516e)
  # 三系统单机运行：NixOS 运行期间 Arch 必为关闭态，可安全读写挂载
  # 开关机时间不固定 → timer Persistent=true，错过计划则开机补跑
  # 同步目标：Arch 的 @home/anan/Documents/vaultwarden-backup
  #   （Arch 侧显示为 /home/anan/Documents/vaultwarden-backup）
  # 注：Vaultwarden 新版已移除内置备份，故用 sqlite3 .backup 在线备份（WAL 安全）
  ############################################
  systemd.services.vaultwarden-sync = {
    description = "Backup Vaultwarden db and sync to Arch disk";

    after = ["vaultwarden.service"];

    path = with pkgs; [
      sqlite # sqlite3 在线备份
      util-linux # mount / umount
      rsync
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
      MP=/mnt/arch-backup
      UUID=9dccd22a-c64e-494b-ab1a-e226b843516e
      DEST="$MP/@home/anan/Documents/vaultwarden-backup"
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
      echo "created $OUT"

      # 本地保留最近 KEEP_DAYS 天
      find "$BACKUP_DIR" -name 'backup-*.db' -mtime +$((KEEP_DAYS - 1)) -delete

      # 同步到 Arch 盘（挂载 → rsync → 卸载）
      mkdir -p "$MP"
      mount -o noatime,subvol=/ UUID="$UUID" "$MP"
      trap 'umount "$MP" || true' EXIT

      mkdir -p "$DEST"
      rsync -a --delete "$BACKUP_DIR/" "$DEST/"
      echo "vaultwarden backups synced to $DEST"

      # 加密盘副本（按需）：vault 已解锁挂载才同步，未解锁跳过，不影响 Arch 那份
      if [ -b /dev/mapper/vault ] && mountpoint -q /mnt/vault; then
        VAULT_DEST=/mnt/vault/vaultwarden/backups
        mkdir -p "$VAULT_DEST"
        # 不删旧文件，加密盘内只增不删，作为长期归档
        rsync -a "$BACKUP_DIR/" "$VAULT_DEST/"
        echo "vaultwarden backups synced to $VAULT_DEST"
      else
        echo "encrypted vault not open, skip vault copy"
      fi
    '';
  };

  systemd.timers.vaultwarden-sync = {
    description = "Daily backup of Vaultwarden and sync to Arch disk";

    wantedBy = ["timers.target"];

    timerConfig = {
      OnCalendar = "daily";
      Persistent = true; # 关机错过计划 → 开机后立即补跑
      RandomizedDelaySec = "5min";
    };
  };
}
