# vars

集中变量。`specialArgs` 以 `myvars` 注入所有模块。

- `default.nix` — `username` / `userfullname` / `useremail` / `homeDirectory` / `repoDir` / `flakeName` / `enableNvidia`
  - `enableNvidia`：独显开关（`false` 屏蔽独显走核显省电；`true` 启用 NVIDIA PRIME offload + RTD3），控制 `configuration.nix` 导入 `nvidia-block.nix` 还是 `nvidia.nix`

新增需要硬编码用户名/路径的地方，优先用 `myvars.xxx` 而不是写死字符串。
