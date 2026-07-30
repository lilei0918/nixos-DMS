{
  config,
  pkgs,
  lib,
  ...
}:
{

  home.packages = with pkgs; [
    thunar
    thunar-volman
    thunar-archive-plugin
    thunar-media-tags-plugin
  ];

  xdg.mimeApps.defaultApplications = {
    "inode/directory" = "thunar.desktop";
    "application/x-gnome-saved-search" = "thunar.desktop";
  };

  # Thunar 配置
  xdg.configFile."xfce4/xfconf/xfce-perchannel-xml/thunar.xml".text = ''
    <?xml version="1.0" encoding="UTF-8"?>

    <channel name="thunar" version="1.0">

      <property name="last-view" type="string" value="ThunarIconView"/>

      <property name="last-show-hidden" type="bool" value="true"/>

      <property name="misc-sort-folders-first" type="bool" value="true"/>

      <property name="misc-date-style" type="int" value="2"/>

      <property name="misc-case-sensitive" type="bool" value="false"/>

    </channel>
  '';
}
