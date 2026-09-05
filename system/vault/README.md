# system/vault

加密数据盘 + Vaultwarden 密码管理器。

- `vault.nix`               LUKS 20G 加密盘（nvme1n1p3，UUID `86c742fc-...`）：`sudo vault-open` / `sudo vault-close` 手动管理
- `vaultwarden.nix`         Podman + Quadlet 容器（SQLite），TLS 走 sops，仅本机 `https://localhost:8080`
- `vaultwarden-backup.nix`  每日两层备份：本地（7 天）+ 加密盘（vault 解锁时才归档，只增不删）
- `certs/`                  Vaultwarden 本地 CA 公钥（私钥在 secrets.yaml）

注意：vault 解锁密码是全部数据的钥匙，务必离线备份；**不要**用 udisks/GNOME Disks 解锁（会破坏 `/mnt/vault` 假设）。详见 `README.md`「四」第 26–28 节。
