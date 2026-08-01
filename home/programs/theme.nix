{
  pkgs,
  config,
  lib,
  ...
}: let
  gtkTheme = {
    name = "WhiteSur-Dark";
  };

  iconTheme = {
    name = "WhiteSur";
  };

  cursorTheme = {
    name = "macOS-White";
    size = 24;
  };
in {
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
      name = gtkTheme.name;

      package = pkgs.whitesur-gtk-theme;
    };

    iconTheme = {
      name = iconTheme.name;

      package = pkgs.whitesur-icon-theme;
    };

    cursorTheme = {
      name = cursorTheme.name;

      size = cursorTheme.size;
    };

    # 不再强制 GTK4 使用 WhiteSur
    #
    # 原来的：
    # gtk4.theme = config.gtk.theme;
    #
    # 删除

    font = {
      name = "Noto Sans CJK";

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
  # Cursor
  # ======================================

  home.pointerCursor = {
    gtk.enable = true;

    enable = true;

    package = pkgs.apple-cursor;

    name = cursorTheme.name;

    size = cursorTheme.size;
  };

  # ======================================
  # 环境变量
  # ======================================

  home.sessionVariables = {
    # 删除 GTK_THEME
    #
    # GTK_THEME=WhiteSur-Dark
    # 会破坏 GTK4

    # 让 Qt/GTK 使用 dark preference

    GTK_APPLICATION_PREFER_DARK_THEME = "1";
  };

  # ======================================
  # Themes
  # ======================================

  home.packages = with pkgs; [
    whitesur-gtk-theme

    whitesur-icon-theme

    adwaita-icon-theme

    gnome-themes-extra
  ];
}
