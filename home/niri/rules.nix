{
  config,
  pkgs,
  ...
}: {
  # 图层规则（注意键名加引号）
  "layer-rules" = [
    {
      matches = [{namespace = "^awww-daemon$";}];
      place-within-backdrop = true;
    }
    # 如果你需要其他图层规则，可以在这里添加
  ];

  # 窗口规则（注意键名加引号）
  "window-rules" = [
    # 1. 通用圆角设置（你原有的）
    {
      matches = [{}];
      geometry-corner-radius = {
        top-left = 20.0;
        top-right = 20.0;
        bottom-left = 20.0;
        bottom-right = 20.0;
      };
      clip-to-geometry = true;
    }

    # 2. 终端（Alacritty 和 Ghostty）固定宽度
    {
      matches = [
        {app-id = "Alacritty";}
        {app-id = "com.mitchellh.ghostty";}
      ];
      default-column-width = {fixed = 800;};
    }

    # 3. 浏览器类（全屏启动）
    {
      matches = [
        {app-id = "zen";}
        {app-id = "firefox";}
        {app-id = "chromium-browser";}
        {app-id = "edge";}
        {app-id = "google-chrome";}
      ];
      open-maximized = true;
    }

    # 4. 普通浏览器窗口（Zed、Chrome、VSCodium 等）占满列宽
    {
      matches = [
        {app-id = "dev.zed.Zed";}
        {app-id = "google-chrome";}
        {app-id = "vscodium";}
        {app-id = "Trae";}
        {app-id = "codium";}
        {app-id = "daA";}
      ];
      default-column-width = {proportion = 1.0;};
    }

    # 6. 浮动窗口类（Telegram、文件管理器等）
    {
      matches = [
        {app-id = "org.telegram.desktop";}
        {app-id = "org.gnome.FileRoller";}
        {app-id = "tauonmb";}
        {app-id = "wechat";}
        {app-id = "QQ";}
        {app-id = "thunar";} # 文件管理器也浮动
      ];
      open-floating = true;
    }

    # 7. 弹窗类窗口居中浮动
    {
      matches = [
        {is-floating = true;}
        {title = "Open File";}
        {title = "Save File";}
        {app-id = "xdg-desktop-portal-gnome";}
      ];
      open-floating = true;
      default-column-width = {fixed = 800;};
      default-window-height = {fixed = 800;};
    }

    # 8. 画中画窗口（Firefox、Zen）
    {
      matches = [
        {
          app-id = "firefox";
          title = "Picture-in-Picture";
        }
        {
          app-id = "zen";
          title = "Picture-in-Picture";
        }
        {title = "Picture in picture";}
      ];
      open-floating = true;
      default-floating-position = {
        x = 32;
        y = 32;
        relative-to = "bottom-right";
      };
      default-column-width = {fixed = 480;};
      default-window-height = {fixed = 270;};
    }

    # 9. 特定应用分配到指定工作区
    {
      matches = [{app-id = "code";}];
      open-on-workspace = "code";
      default-column-width = {proportion = 0.75;};
    }
    {
      matches = [{app-id = "com.mitchellh.ghostty";}];
      open-on-workspace = "terminal";
      default-column-width = {proportion = 0.5;};
    }

    {
      matches = [{app-id = "mpv";}];
      open-on-workspace = "media";
      open-floating = true;
    }
    {
      matches = [{app-id = "org.telegram.desktop";}];
      open-floating = true;
    }
    {
      matches = [{app-id = "com.github.johnfactotum.Foliate";}];
      open-floating = true;
    }
    {
      matches = [{app-id = "htop";}];
      open-on-workspace = "terminal";
      open-floating = true;
    }

    # 10. 非活动窗口透明度（如果需要）
    # {
    #   matches = [{ is-active = false; }];
    #   opacity = 0.9;
    # }

    # 11. 思源笔记独占一列
    {
      matches = [{app-id = "SiYuan";}];
      default-column-width = {proportion = 1.0;};
    }

    {
      matches = [{app-id = "thunar";}];

      open-floating = true;

      default-column-width = {
        fixed = 1200;
      };

      default-window-height = {
        fixed = 800;
      };
    }
  ];
}
