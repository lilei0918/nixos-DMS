{
  pkgs,
  config,
  lib,
  ...
}:
let
  theme = {
    name = "WhiteSur-Dark";
    icon = "WhiteSur";
    cursor = "macOS-White";
    cursorSize = 24;
  };
in
{
  # 用户级 GTK 主题
  gtk = {
    enable = true;
    theme = {
      name = theme.name;
      package = pkgs.whitesur-gtk-theme;
    };
    iconTheme = {
      name = theme.icon;
      package = pkgs.whitesur-icon-theme;
    };
    cursorTheme = {
      name = theme.cursor;
      size = theme.cursorSize;
    };
    gtk4.theme = config.gtk.theme;
  };

  # Qt 主题（修正）
  qt = {
    enable = true;

    platformTheme = {
      name = "gtk3";
    };

    style = {
      name = "gtk3";
    };
    # 如果你不需要 style，可以注释掉
    # style = null;
  };

  # 用户光标设置
  home.pointerCursor = {
    gtk.enable = true;
    enable = true;

    package = pkgs.apple-cursor;
    name = theme.cursor;
    size = theme.cursorSize;
  };

  # 环境变量
  home.sessionVariables = {
    GTK_THEME = theme.name;
  };

  # 安装主题包
  home.packages = with pkgs; [
    whitesur-gtk-theme
    whitesur-icon-theme
  ];
}
