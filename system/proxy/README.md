# system/proxy

代理方案。**clash-verge / mihomo 二选一，不可同时开启**。

- `clash-verge.nix` 【当前启用】Clash Verge Rev（nixpkgs 官方模块 `programs.clash-verge`）：serviceMode + tunMode + autoStart；GUI 加订阅并开 Tun
- `mihomo.nix`     【备用】mihomo TUN 模式；切回时注释 clash-verge 的 import 并改引本文件

注意：
- 切换点：`hosts/legion/configuration.nix` 的 `proxy` import 区块（已注释互斥项）
- clash-verge：TUN 所需 capabilities 由官方模块经 `security.wrappers` 授予；`checkReversePath` 已默认/显式 `loose`（`network.nix`）
- clash-verge 单实例：`serviceMode` 的 systemd 服务常驻，GUI 需开启「服务模式」复用该核心，否则会另起一个核心
- 防火墙规则随各自模块内联，未盲目放行端口
