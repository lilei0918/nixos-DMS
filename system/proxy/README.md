# system/proxy

代理方案。**clash-verge / daed / mihomo 三选一，不可同时开启**。

- `clash-verge.nix` 【当前启用】Clash Verge Rev（nixpkgs 官方模块 `programs.clash-verge`）：serviceMode + tunMode + autoStart；GUI 加订阅并开 Tun
- `daed.nix`     【备用】daed = dae eBPF 透明代理 + Web 面板（`http://127.0.0.1:2023`）
- `mihomo.nix`   【备用】mihomo TUN 模式；切回时注释 clash-verge 的 import 并改引相应文件

注意：
- 切换点：`hosts/legion/configuration.nix` 的 `proxy` import 区块（已注释互斥项）
- clash-verge：TUN 所需 capabilities 由官方模块经 `security.wrappers` 授予；`checkReversePath` 已默认/显式 `loose`（`network.nix`）
- daed 面板初始化 tproxy_port 填 **12345**；规则库用 `v2ray-rules-dat`（含 gfw）；garnix 缓存注释禁用
- daeuniverse `flake.nix` input 仅 daed 备用需要，可暂留
- 防火墙规则随各自模块内联，未盲目放行端口
