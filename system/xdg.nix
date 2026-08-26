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
      };
    };
  };
}
