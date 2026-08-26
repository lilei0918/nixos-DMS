{pkgs, ...}: {
  home.packages = with pkgs; [
    thunar
    xfconf # xfconfd（Thunar 设置经 D-Bus 需要它，否则 XML 配置不生效）
    thunar-volman
    thunar-archive-plugin
    thunar-media-tags-plugin
  ];

  xdg.mimeApps.defaultApplications = {
    "inode/directory" = "thunar.desktop";
    "application/x-gnome-saved-search" = "thunar.desktop";
  };

  # Thunar 配置（HM xfconf 模块：经 xfconf-query 写入 D-Bus，由 xfconfd 持久化）
  # 相比手写 thunar.xml 的优势：
  #   1. 无需 force = true 补丁（xfconfd 运行时改写文件不再与 HM 符号链接冲突）
  #   2. 运行时在 Thunar UI 里改设置不会被下次 rebuild 覆盖
  xfconf.settings.thunar = {
    last-view = "ThunarIconView";
    last-show-hidden = true;
    last-sort-column = "THUNAR_COLUMN_NAME";
    last-sort-order = "GTK_SORT_ASCENDING";
    misc-folders-first = true;
    misc-date-style = 2;
    misc-case-sensitive = false;
  };
}
