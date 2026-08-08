_: {
  # 窗口规则（注意键名加引号）
  # app-id 用正则子串匹配即可（如 "libreoffice" 同时命中 writer/calc/impress）
  "window-rules" = [
    # 1. 通用圆角设置
    {
      matches = [{}];
      geometry-corner-radius = {
        top-left = 10.0;
        top-right = 10.0;
        bottom-left = 5.0;
        bottom-right = 5.0;
      };
      clip-to-geometry = true;
    }

    # 2. 终端固定宽度
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
        {app-id = "google-chrome";}
        {app-id = "firefox";}
      ];
      open-maximized = true;
    }

    # 4. 开发工具占满列宽
    {
      matches = [
        {app-id = "dev.zed.Zed";}
        {app-id = "codium";}
      ];
      default-column-width = {proportion = 1.0;};
    }

    # 5. 办公 / 编辑器占满列宽
    {
      matches = [
        {app-id = "libreoffice";}
        {app-id = "zettlr";}
        {app-id = "TradingView";}
        {app-id = "org.gnome.TextEditor";}
      ];
      default-column-width = {proportion = 1.0;};
    }

    # 6. 浮动窗口类（工具 / 对话框型应用）
    {
      matches = [
        {app-id = "org.gnome.FileRoller";}
        {app-id = "org.pulseaudio.pavucontrol";}
        {app-id = "com.rafaelmardojai.Blanket";}
        {app-id = "localsend_app";}
        {app-id = "ca.desrt.dconf-editor";}
        {app-id = "waypaper";}
        {app-id = "nwg-look";}
        {app-id = "qt6ct";}
        {app-id = "org.gnome.Loupe";}
        {app-id = "zathura";}
        {app-id = "com.github.johnfactotum.Foliate";}
        {app-id = "hermes";}
      ];
      open-floating = true;
    }

    # 6.1 QQ 浮动 + 固定宽度（1600 的 2 倍）
    {
      matches = [{app-id = "QQ";}];
      open-floating = true;
      default-column-width = {fixed = 1600;};
    }

    # 7. 弹窗类窗口居中浮动
    {
      matches = [
        {title = "Open File";}
        {title = "Save File";}
      ];
      open-floating = true;
      default-column-width = {fixed = 800;};
      default-window-height = {fixed = 800;};
    }

    # 8. 画中画窗口（Firefox）
    {
      matches = [
        {
          app-id = "firefox";
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
      matches = [{app-id = "codium";}];
      open-on-workspace = "code";
    }
    {
      matches = [{app-id = "dev.zed.Zed";}];
      open-on-workspace = "code";
    }
    {
      # 终端类：不分配工作区，保持浮动
      matches = [
        {app-id = "Alacritty";}
        {app-id = "com.mitchellh.ghostty";}
        {app-id = "htop";}
      ];
      open-floating = true;
    }
    {
      # mpv 媒体播放器：无专用工作区，保持浮动（当前工作区）
      matches = [{app-id = "mpv";}];
      open-floating = true;
    }

    # 9.5 浏览器分配到 browser 工作区
    {
      matches = [
        {app-id = "google-chrome";}
        {app-id = "firefox";}
      ];
      open-on-workspace = "browser";
    }

    # 10. 思源笔记独占一列，分配到 note 工作区
    {
      matches = [{app-id = "org.b3log.siyuan";}];
      open-on-workspace = "note";
      default-column-width = {proportion = 1.0;};
    }

    # 11. Thunar 浮动 + 固定尺寸
    {
      matches = [{app-id = "Thunar";}];

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
