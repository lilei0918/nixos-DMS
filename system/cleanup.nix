{myvars, ...}: {
  ############################################
  # 系统日志上限（journal）
  # 默认无上限会一直涨到占满 /var/log；压到 50M，超过自动轮转删除
  ############################################

  services.journald.extraConfig = ''
    SystemMaxUse=50M
    SystemKeepFree=1G
  '';

  ############################################
  # 用户缓存自动清理
  # 用 tmpfiles 的年龄规则：只删除超过 3天的条目，
  # 由 systemd 自带的 systemd-tmpfiles-clean.timer 每日自动执行，
  # 不需要每次开机清空（保留最近缓存加速日常使用）。
  # 格式：d <目录> <模式> <属主> <组> <年龄>
  ############################################

  systemd.tmpfiles.rules = [
    # Python 包管理缓存（体积大户）
    "d ${myvars.homeDirectory}/.cache/uv - - - 3d"
    "d ${myvars.homeDirectory}/.cache/pip - - - 3d"

    # Nix 下载缓存
    "d ${myvars.homeDirectory}/.cache/nix - - - 3d"

    # 剪贴板历史（elephant）
    "d ${myvars.homeDirectory}/.cache/elephant - - - 3d"

    # 浏览器缓存（默认不自动清，避免每次开机重新下载网页资源拖慢体验；
    # 想要的话取消下面两行注释，设 7 天以上比较合理）
    # "d ${myvars.homeDirectory}/.cache/google-chrome - - - 7d"
    # "d ${myvars.homeDirectory}/.cache/mozilla - - - 7d"
  ];
}
