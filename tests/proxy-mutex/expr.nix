{outputs, ...}:
# 代理二选一：daed 主用启用，mihomo 备用必须关闭
outputs.nixosConfigurations.legion.config.services.daed.enable && !outputs.nixosConfigurations.legion.config.services.mihomo.enable
