{config, ...}: let
  home = config.home.homeDirectory;
in {
  # ============================================================
  # Downloads 里的 AppImage 启动项（供 walker / 应用菜单使用）
  #
  # NixOS 上 AppImage 统一经 `appimage-run` 启动（系统已装，
  # 见 system/packages.nix），它会处理 FUSE/依赖，避免直接执行失败。
  #
  # 图标用 freedesktop 通用名（AppImage 自带图标未提取）；
  # 若 AppImage 被移动/删除，对应启动项会失效，请同步改此文件。
  # ============================================================

  xdg.desktopEntries = {
    folo = {
      name = "Folo";
      comment = "Follow everything in one place";
      exec = "appimage-run ${home}/Downloads/Folo-1.13.0-linux-x64.AppImage";
      icon = "applications-internet";
      categories = ["Network" "News"];
      terminal = false;
      type = "Application";
    };

    localsend = {
      name = "LocalSend";
      comment = "Share files to nearby devices";
      exec = "appimage-run ${home}/Downloads/LocalSend-1.17.0-linux-x86-64.AppImage";
      icon = "network-transmit-receive";
      categories = ["Network" "Utility"];
      terminal = false;
      type = "Application";
    };
  };
}
