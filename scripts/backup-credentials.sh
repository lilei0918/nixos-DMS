#!/usr/bin/env bash
# backup-credentials.sh — 备份「信任根 / 凭据」到加密盘（默认 /mnt/vault/credentials-backup）
#
# 仅备份以下关键小文件（不含任何业务数据）：
#   /etc/sops/age/keys.txt                   系统 sops 解密钥匙（README「十二」第 6 条）
#   ~/.config/sops/age/keys.txt              用户级 sops 解密钥匙（编辑 secrets.yaml 需要）
#   ~/.ssh/                                  git push 凭据（id_ed25519 / config / known_hosts）
#   ~/.local/share/opencode/auth.json        opencode 凭据
#
# 用法：
#   sudo bash scripts/backup-credentials.sh                  # 备份到 /mnt/vault/credentials-backup
#   sudo bash scripts/backup-credentials.sh /media/usb/backup  # 备份到指定目录
#   sudo DRY_RUN=1 KEEP=5 bash scripts/backup-credentials.sh   # 演练（只打印计划，不写文件）
#
# 说明：
#   - 需要 root（读取 /etc/sops/age/keys.txt 并写入加密盘）；建议配合 `sudo vault-open` 使用
#   - 全程不在终端打印任何文件内容，只打印路径与校验结果
#   - 每次生成日期目录 + SHA256SUMS 校验清单，并更新 latest 软链；默认保留最近 5 份
#   - 备份完成后目录/文件属主改为当前用户（700/600，仅属主可读写），Thunar 可直接打开；
#     之前 root:root 700 造成无法访问的历史目录，重跑一次本脚本即会被修正

set -euo pipefail

DEST_ROOT="${1:-/mnt/vault/credentials-backup}"
LILEI_HOME="${LILEI_HOME:-/home/lilei}"
KEEP="${KEEP:-5}"
DRY_RUN="${DRY_RUN:-0}"
# 备份完成后把属主改为用户（脚本需 root 运行，但目录要 lilei 用 Thunar 可访问）
OWNER="${SUDO_USER:-lilei}"

# 防止误把整盘/加密盘根作为目标（会 chown -R 整个 vault）
if [[ "$DEST_ROOT" == "/" || "$DEST_ROOT" == "/mnt/vault" ]]; then
  echo "目标目录不安全（$DEST_ROOT），请使用子目录，如 /mnt/vault/credentials-backup" >&2
  exit 1
fi

# 源文件:目标名（: 分隔）
SOURCES=(
  "/etc/sops/age/keys.txt:etc-sops-age-keys.txt"
  "${LILEI_HOME}/.config/sops/age/keys.txt:home-sops-age-keys.txt"
  "${LILEI_HOME}/.ssh:home-ssh"
  "${LILEI_HOME}/.local/share/opencode/auth.json:home-opencode-auth.json"
)

if [[ $EUID -ne 0 ]]; then
  echo "需要 root（读取系统 sops 钥匙、写入加密盘）。请用: sudo bash $0 $*" >&2
  exit 1
fi

# 默认目标是加密盘时，确认已解锁挂载
if [[ "$DEST_ROOT" == /mnt/vault* ]] && ! mountpoint -q /mnt/vault; then
  echo "加密盘未挂载，请先: sudo vault-open" >&2
  exit 1
fi

TS=$(date +%Y%m%d-%H%M%S)
DEST="$DEST_ROOT/$TS"

plan() {
  echo "[plan] $*"
}

if [[ "$DRY_RUN" == 1 ]]; then
  plan "备份目标: $DEST（属主: $OWNER，权限 700/600）"
  for entry in "${SOURCES[@]}"; do
    src="${entry%%:*}"
    name="${entry#*:}"
    if [[ -e "$src" ]]; then
      plan "备份   $src -> $DEST/$name"
    else
      plan "SKIP   $src（不存在）"
    fi
  done
  exit 0
fi

install -d -m 700 "$DEST_ROOT"
mkdir -p "$DEST"
chmod 700 "$DEST"

fail=0
: > "$DEST/SHA256SUMS"
for entry in "${SOURCES[@]}"; do
  src="${entry%%:*}"
  name="${entry#*:}"
  if [[ ! -e "$src" ]]; then
    echo "SKIP  $src（不存在）"
    continue
  fi

  if [[ -d "$src" ]]; then
    install -d -m 700 "$DEST/$name"
    cp -a "$src"/. "$DEST/$name/"
    chmod -R go-rwx "$DEST/$name"
    if diff -rq "$src" "$DEST/$name" >/dev/null; then
      echo "OK    $src -> $DEST/$name/"
    else
      echo "FAIL  $src -> $DEST/$name/（校验不一致）" >&2
      fail=1
    fi
    (cd "$DEST/$name" && find . -type f -exec sha256sum {} +) >> "$DEST/SHA256SUMS"
  else
    install -m 600 "$src" "$DEST/$name"
    if cmp -s "$src" "$DEST/$name"; then
      echo "OK    $src -> $DEST/$name"
    else
      echo "FAIL  $src -> $DEST/$name（校验不一致）" >&2
      fail=1
    fi
    (cd "$DEST" && sha256sum "$name") >> "$DEST/SHA256SUMS"
  fi
done

# 权限收紧：目录内全部仅属主可读写
chmod -R go-rwx "$DEST"
chmod 600 "$DEST/SHA256SUMS"

# 属主改为用户（含 base 目录与历史备份），否则 root:root 700 下 Thunar 无法访问
chown -R "$OWNER" "$DEST_ROOT"

# latest 软链指向本次备份
ln -sfn "$TS" "$DEST_ROOT/latest"
chown -h "$OWNER" "$DEST_ROOT/latest"

# 清理：保留最近 KEEP 份
if [[ -d "$DEST_ROOT" ]]; then
  mapfile -t old < <(find "$DEST_ROOT" -maxdepth 1 -type d -name '2*' | sort -r | tail -n +$((KEEP + 1)))
  for d in "${old[@]}"; do
    echo "PRUNE $d"
    rm -rf "$d"
  done
fi

echo "备份完成: $DEST"
echo "恢复示例: sudo cp -a $DEST/* /（各文件回原路径，见 README「十二」第 6 条）"
exit "$fail"
