_: {
  # 后台服务的启动器（供 walker / 应用菜单手动启停）
  # 对应服务已取消自启：
  #   - Immich 整套（system/immich.nix 清掉了 wantedBy）
  #   - Trading News Hub（hosts/legion/home.nix 清掉了 Install.WantedBy）
  #
  # Immich 是系统服务：经 pkexec 调用 systemctl，polkit 会弹一次授权窗。
  # 手动启动时显式拉起 Postgres/Redis/ML/Server，不依赖自启顺序。

  xdg.desktopEntries = {
    "immich-start" = {
      name = "Immich 启动";
      comment = "启动 Immich 照片库（需授权）";
      exec = "/run/wrappers/bin/pkexec /run/current-system/sw/bin/systemctl start postgresql.target redis-immich.service immich-machine-learning.service immich-server.service";
      icon = "media-playback-start";
      categories = ["System"];
      terminal = false;
      type = "Application";
    };

    "immich-stop" = {
      name = "Immich 停止";
      comment = "停止 Immich 照片库（需授权）";
      exec = "/run/wrappers/bin/pkexec /run/current-system/sw/bin/systemctl stop immich-server.service immich-machine-learning.service redis-immich.service postgresql.target";
      icon = "media-playback-stop";
      categories = ["System"];
      terminal = false;
      type = "Application";
    };

    "trading-news-hub-start" = {
      name = "Trading News Hub 启动";
      comment = "启动 tnh 新闻采集/通知（用户服务）";
      exec = "/run/current-system/sw/bin/systemctl --user start trading-news-hub";
      icon = "media-playback-start";
      categories = ["System"];
      terminal = false;
      type = "Application";
    };

    "trading-news-hub-stop" = {
      name = "Trading News Hub 停止";
      comment = "停止 tnh 新闻采集/通知（用户服务）";
      exec = "/run/current-system/sw/bin/systemctl --user stop trading-news-hub";
      icon = "media-playback-stop";
      categories = ["System"];
      terminal = false;
      type = "Application";
    };
  };
}
