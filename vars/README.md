# vars

集中变量。`specialArgs` 以 `myvars` 注入所有模块。

- `default.nix` — `username` / `userfullname` / `useremail` / `homeDirectory` / `repoDir` / `flakeName`

新增需要硬编码用户名/路径的地方，优先用 `myvars.xxx` 而不是写死字符串。
