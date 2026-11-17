# secrets

sops（age 加密）机密文件。

- `secrets.yaml` 已用 age 加密，可提交 git，但**不要直接打开/编辑**；请用 `sops secrets/secrets.yaml` 编辑（明文输入、保存自动加密）
- 密钥项：`deepseek_api_key` / `vaultwarden_admin_token` / `password_hash` / `vaultwarden_tls_*` / `binance_api_key` / `binance_api_secret`
- 信任根：`/etc/sops/age/keys.txt`（age 私钥，**绝不可提交**，已备份到 Win11 数据盘和 QQ 邮箱）
- `binance_api_key` / `binance_api_secret`：Aoying Radar 只读账户 API（系统级 `system/secrets.nix` 生成 `/run/secrets/aoying-radar-env`，程序仅调用只读接口）

新增密钥流程见 `README.md`「八」第 4 条；信任根备份/恢复见 `README.md`「十二」第 6 条。
