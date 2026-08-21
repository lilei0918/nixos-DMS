# scripts

本目录存放本仓库的运维辅助脚本（非 Nix 模块，直接以 shell 脚本形式提交，可在 rebuild 前/新机恢复阶段使用）。

| 脚本 | 作用 |
|------|------|
| `backup-credentials.sh` | 备份「信任根 / 凭据」到加密盘（默认 `/mnt/vault/credentials-backup`） |

## backup-credentials.sh — 信任根/凭据备份

### 作用

把重装/换机必需的**钥匙与凭据**（不包含业务数据）备份到加密盘，用于新机器复原。
备份内容固定为以下源（不存在的源自动跳过）：

| 源路径 | 备份名 | 说明 |
|--------|--------|------|
| `/etc/sops/age/keys.txt` | `etc-sops-age-keys.txt` | 系统 sops 解密钥匙（信任根，见 README「十二」第 6 条） |
| `~/.config/sops/age/keys.txt` | `home-sops-age-keys.txt` | 用户级 sops 解密钥匙（跑 `sops secrets/secrets.yaml` 需要） |
| `~/.ssh/` | `home-ssh/` | git push 凭据（id_ed25519 / config / known_hosts 等） |
| `~/.local/share/opencode/auth.json` | `home-opencode-auth.json` | opencode 凭据 |
| `~/.config/mihomo/config.yaml` | `home-mihomo-config.yaml` | mihomo 订阅配置（含订阅 token；启用 mihomo 时才有） |
| `~/.pi/agent/auth.json` | `home-pi-auth.json` | pi coding agent 认证 |
| `/var/lib/hermes/.hermes/auth.json` | `var-lib-hermes-auth.json` | hermes 系统服务认证状态 |

### 用法

```bash
sudo vault-open                            # 加密盘未解锁时先开
sudo bash scripts/backup-credentials.sh    # 备份到 /mnt/vault/credentials-backup（默认保留 5 份）

# 指定其他目标目录
sudo bash scripts/backup-credentials.sh /media/usb/backup

# 演练：只打印计划，不写文件
sudo DRY_RUN=1 bash scripts/backup-credentials.sh

# 环境变量
#   KEEP=5         保留最近备份份数（默认 5，超出自动清理）
#   LILEI_HOME=... 用户主目录（默认 /home/lilei）
```

脚本需 **root**（读取系统 sops 钥匙、写入加密盘）；用 `sudo` 运行时会自动把备份属主改为当前用户。

### 输出结构

```text
/mnt/vault/credentials-backup/
├── 20260816-152030/          # 每次运行的日期目录
│   ├── SHA256SUMS            # 校验清单（恢复后可用来验证完整性）
│   ├── etc-sops-age-keys.txt # 600
│   ├── home-sops-age-keys.txt# 600
│   ├── home-opencode-auth.json  # 600
│   ├── home-mihomo-config.yaml  # 600（存在时）
│   ├── home-pi-auth.json        # 600（存在时）
│   ├── var-lib-hermes-auth.json # 600（存在时）
│   └── home-ssh/             # 700，内含 id_ed25519 等
└── latest -> 20260816-152030 # 软链，指向最新一份
```

### 权限与属主

- 目录 `700`、文件 `600`，仅属主可读写（**不会**打印/透传任何文件内容到终端）。
- 属主自动改为当前用户（`SUDO_USER`，默认 `lilei`），因此 **Thunar 可直接打开浏览**。
- ⚠️ 若看到备份目录打不开，说明是旧脚本生成的 `root:root 700`；重跑一次本脚本即可把属主修正为当前用户，或手动执行：
  ```bash
  sudo chown -R lilei:lilei /mnt/vault/credentials-backup
  ```

### 恢复（新机器）

1. 开加密盘：`sudo vault-open`
2. 恢复各文件到原路径：
   ```bash
   sudo cp /mnt/vault/credentials-backup/latest/etc-sops-age-keys.txt /etc/sops/age/keys.txt
   sudo cp /mnt/vault/credentials-backup/latest/home-sops-age-keys.txt ~/.config/sops/age/keys.txt
   cp -a /mnt/vault/credentials-backup/latest/home-ssh/. ~/.ssh/
   mkdir -p ~/.local/share/opencode
   cp /mnt/vault/credentials-backup/latest/home-opencode-auth.json ~/.local/share/opencode/auth.json
   sudo chmod 600 /etc/sops/age/keys.txt ~/.config/sops/age/keys.txt
   ```
3. 之后按 README「十一、重装流程」rebuild 即可，密码 hash / Vaultwarden TLS 全自动。

### 故障排查

| 现象 | 处理 |
|------|------|
| 提示「加密盘未挂载」 | 先 `sudo vault-open` |
| 提示「需要 root」 | 加 `sudo` 运行 |
| 提示「目标目录不安全」 | 目标不能是 `/` 或 `/mnt/vault` 根，请用子目录 |
| 输出 `FAIL ...（校验不一致）` | 源文件复制后校验失败，源文件可能在备份过程中被修改；重跑一次 |
| Thunar 打不开备份目录 | 见上方「权限与属主」，重跑脚本或 `chown -R lilei:lilei` |
| 恢复后 `sops` 仍解不开 | 确认 `/etc/sops/age/keys.txt` 与 `~/.config/sops/age/keys.txt` 都已恢复且 `600`，公钥对应 README「十二」第 6 条 |

### 设计要点

- 只读源文件、写入加密盘，全程不打印文件内容。
- 每次独立日期目录 + `SHA256SUMS`，便于增量核对与回滚。
- `latest` 软链保证恢复时总是指向最新一份。
- 自动清理（默认保留 5 份）仅作用于本目录下 `2*` 开头的日期目录，不影响其他文件。
- 备份是**钥匙/凭据**快照，非完整数据备份；业务数据（DATATB、SiYuan、Vaultwarden 库等）需另行备份（见 README「重装流程」）。
