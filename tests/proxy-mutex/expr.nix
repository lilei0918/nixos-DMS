{outputs, ...}:
# 代理二选一：clash-verge 主用启用；mihomo 备用若被导入则必须关闭
let
  c = outputs.nixosConfigurations.legion.config;
in
  c.programs."clash-verge".enable
  && !(c ? services.mihomo.enable && c.services.mihomo.enable)
