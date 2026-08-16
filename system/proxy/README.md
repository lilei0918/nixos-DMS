# system/proxy

代理方案。**daed 与 mihomo 二选一，不可同时开启**。

- `daed.nix`   【当前启用】daed = dae eBPF 透明代理 + Web 面板（`http://127.0.0.1:2023`）
- `mihomo.nix` 【备用】mihomo TUN 模式；切回时注释 daed 的 import 并改引本文件

注意：
- daed 面板初始化 tproxy_port 填 **12345**（与 `openFirewall.port` 一致）
- 规则库用 `v2ray-rules-dat`（含 gfw 分类），默认 community 版会报 `code gfw not found`
- garnix 二进制缓存已注释禁用（常 503）；`daeuniverse` input 的 nixpkgs pin 到 `b12141ef`（pnpm 10.x）
- 防火墙规则随各自模块内联（daed 仅 `checkReversePath=loose`；mihomo 含 `Meta` 放行 + 端口）

详见 `README.md`「四」第 16 / 17 节。
