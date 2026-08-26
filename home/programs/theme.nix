{
  pkgs,
  myvars,
  ...
}: {
  # ======================================
  # GTK
  # ======================================

  gtk = {
    enable = true;

    # GTK4 使用系统默认（null），不再强制 WhiteSur
    # （旧默认是跟随 gtk.theme，home.stateVersion < 26.05 时会警告）
    gtk4.theme = null;

    # GTK3 应用
    theme = {
      name = myvars.theme.gtk;

      package = pkgs.whitesur-gtk-theme;
    };

    iconTheme = {
      name = myvars.theme.icon;

      package = pkgs.whitesur-icon-theme;
    };

    cursorTheme = {
      name = myvars.theme.cursor;

      size = myvars.theme.cursorSize;
    };

    font = {
      name = "Inter";

      size = 11;
    };
  };

  # ======================================
  # Qt
  # ======================================

  qt = {
    enable = true;

    # 走 GTK 平台主题，让 Qt 应用跟随 GTK2 配色/字体
    platformTheme = {
      name = "gtk3";
    };

    # ⚠️ "gtk3" 不是合法 QStyle（HM 会导出 QT_STYLE_OVERRIDE 并被 Qt 拒绝告警）；
    # platformTheme 已足够，style 留空让 Qt 用默认
    style = {
      name = null;
    };
  };

  # ======================================
  # Cursor / Env / Theme packages
  # ======================================

  home = {
    # ======================================
    # Cursor
    # ======================================

    pointerCursor = {
      gtk.enable = true;

      enable = true;

      package = pkgs.apple-cursor;

      name = myvars.theme.cursor;

      size = myvars.theme.cursorSize;
    };

    # ======================================
    # 环境变量
    # ======================================

    sessionVariables = {
      # 删除 GTK_THEME
      #
      # GTK_THEME=WhiteSur-Dark
      # 会破坏 GTK4

      # 让 Qt/GTK 使用 dark preference

      GTK_APPLICATION_PREFER_DARK_THEME = "1";

      # Wayland 下部分应用不读 GTK 设置，显式声明光标主题/尺寸
      XCURSOR_THEME = myvars.theme.cursor;

      XCURSOR_SIZE = toString myvars.theme.cursorSize;

      # 注：QT_QPA_PLATFORMTHEME 由 HM qt 模块按 platformTheme.name 自动导出，勿手写
    };

    # ======================================
    # Themes
    # ======================================

    packages = with pkgs; [
      whitesur-gtk-theme

      whitesur-icon-theme

      adwaita-icon-theme

      gnome-themes-extra
    ];
  };
}
