# tests

flake 求值测试（`nix flake check` 自动运行，经 `checks.evalTestsCheck` 强制求值，失败即抛错）。

- `default.nix` 自动发现各测试子目录（`expr.nix` + `expected.nix`），断言二者相等
- 现有测试：`home-directory` / `state-version` / `timezone` / `user-is-normal` / `proxy-mutex` / `firefox-disabled` / `hm-state-version`

新增测试：建 `tests/<name>/`，`expr.nix` 用 `outputs.nixosConfigurations.legion.config...` 取实际值，`expected.nix` 给期望值。
