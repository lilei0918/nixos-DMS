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

  # Thunar 配置
  # force = true：xfconf 运行时会改写该文件（破坏符号链接），
  # 若不 force 则重建时会因 backup 文件已存在而激活失败
  xdg.configFile."xfce4/xfconf/xfce-perchannel-xml/thunar.xml" = {
    force = true;

    text = ''
      <?xml version="1.0" encoding="UTF-8"?>

      <channel name="thunar" version="1.0">

        <property name="last-view" type="string" value="ThunarIconView"/>

        <property name="last-show-hidden" type="bool" value="true"/>

        <property name="last-sort-column" type="string" value="THUNAR_COLUMN_NAME"/>

        <property name="last-sort-order" type="string" value="GTK_SORT_ASCENDING"/>

        <property name="misc-folders-first" type="bool" value="true"/>

        <property name="misc-date-style" type="int" value="2"/>

        <property name="misc-case-sensitive" type="bool" value="false"/>

      </channel>
    '';
  };
}
