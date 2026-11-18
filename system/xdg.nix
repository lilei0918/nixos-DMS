{pkgs, ...}: {
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      # niri 的 ScreenCast（录屏/截图走 portal）需要 gnome 后端实现；
      # gtk 后端只提供 file-chooser 等基础接口，作为兜底保留
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
    config = {
      niri = {
        default = [
          "gnome"
          "gtk"
        ];

        # 修复：gnome 后端的 FileChooser 委派失败
        # （journal 报 "Delegated FileChooser call failed: The name is not activatable"，
        #   缺少可激活的 org.gnome.portal.filechooser 服务），
        # 强制文件选择走 gtk 后端（xdg-desktop-portal-gtk 自带可用实现）。
        # 注意：default 仍保留 gnome 在前，供 ScreenCast 等接口使用。
        # Luciole 自带 FileChooser 后端（luciole.portal）：首选 luciole，gtk 兜底。
        "org.freedesktop.impl.portal.FileChooser" = [
          "luciole"
          "gtk"
        ];
      };
    };
  };
}
