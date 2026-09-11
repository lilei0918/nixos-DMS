_: {
  ############################################
  # 系统日志上限（journal）
  # 默认无上限会一直涨到占满 /var/log；压到 200M，超过自动轮转删除。
  ############################################

  services.journald.settings.Journal = {
    SystemMaxUse = "200M";
    SystemKeepFree = "1G";
  };

  # 用户缓存 ~/.cache 已是 tmpfs（见 system/tmpfs.nix），重启即空，
  # 无需再用 tmpfiles 年龄规则清理。
}
