# system/vault/certs

Vaultwarden 本地 CA 公钥：`vaultwarden-ca.crt`。

- 经 `security.pki.certificateFiles` 写入系统信任（浏览器零警告）
- 私钥（ca.key / server.key 等）走 sops 加密存于 `secrets/secrets.yaml` 的 `vaultwarden_tls_*`，rebuild 时解密到 `/var/lib/vaultwarden/tls/`

换证书流程见 `README.md`「四」第 27 节。
