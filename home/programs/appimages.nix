{
  config,
  pkgs,
  ...
}: let
  home = config.home.homeDirectory;

  # Folo 会在 ~/Downloads 里留下多个版本的 AppImage（手动下载新版后旧文件还在）。
  # 启动时取 mtime 最新的那个，这样升级 Folo 不必再改 NixOS 配置。
  folo = pkgs.writeShellScriptBin "folo" ''
    set -euo pipefail
    app=$(ls -1t "$HOME"/Downloads/Folo-*-linux-x64.AppImage 2>/dev/null | head -1)
    if [ -z "$app" ]; then
      echo "找不到 Folo AppImage：~/Downloads/Folo-*-linux-x64.AppImage" >&2
      echo "去 https://github.com/RSSNext/Folo/releases 下载后放到 ~/Downloads 即可" >&2
      exit 1
    fi
    exec ${pkgs.appimage-run}/bin/appimage-run "$app" "$@"
  '';
in {
  # ============================================================
  # Downloads 里的 AppImage 启动项（供 walker / 应用菜单使用）
  #
  # NixOS 上 AppImage 统一经 `appimage-run` 启动（系统已装，
  # 见 system/packages.nix），它会处理 FUSE/依赖，避免直接执行失败。
  #
  # 图标用 freedesktop 通用名（AppImage 自带图标未提取）；
  # Folo 走 `folo` 包装脚本（自动选 ~/Downloads 里最新的版本）；
  # LocalSend 仍写死版本号，若 AppImage 被移动/删除需同步改此文件。
  # ============================================================

  home.packages = [folo];

  xdg.desktopEntries = {
    folo = {
      name = "Folo";
      comment = "Follow everything in one place";
      exec = "folo";
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
