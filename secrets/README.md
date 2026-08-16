# secrets

sops（age 加密）机密文件。

- `secrets.yaml` 已用 age 加密，可提交 git，但**不要直接打开/编辑**；请用 `sops secrets/secrets.yaml` 编辑（明文输入、保存自动加密）
- 密钥项：`deepseek_api_key` / `vaultwarden_admin_token` / `password_hash` / `vaultwarden_tls_*`
- 信任根：`/etc/sops/age/keys.txt`（age 私钥，**绝不可提交**，已备份到 Win11 数据盘和 QQ 邮箱）

新增密钥流程见 `README.md`「八」第 4 条；信任根备份/恢复见 `README.md`「十二」第 6 条。
