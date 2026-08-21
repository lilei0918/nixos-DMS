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

    # 不再强制 GTK4 使用 WhiteSur
    #
    # 原来的：
    # gtk4.theme = config.gtk.theme;
    #
    # 删除

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

    platformTheme = {
      name = "gtk3";
    };

    style = {
      name = "gtk3";
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

      # Qt 统一走 GTK platform theme（Qt5/Qt6 都生效，避免 KDE 风格割裂）
      QT_QPA_PLATFORMTHEME = "gtk3";
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
