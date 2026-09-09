{outputs, ...}:
# 代理三选一：clash-verge 主用启用；daed / mihomo 备用若被导入则必须关闭
let
  c = outputs.nixosConfigurations.legion.config;
in
  c.programs."clash-verge".enable
  && !(c ? services.daed.enable && c.services.daed.enable)
  && !(c ? services.mihomo.enable && c.services.mihomo.enable)
