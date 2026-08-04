{pkgs, ...}: {
  xdg.portal = {
    enable = true;
    # 只保留 gtk 后端，这是最稳定的选择
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
    config = {
      niri = {
        default = ["gtk"];
      };
    };
  };
}
