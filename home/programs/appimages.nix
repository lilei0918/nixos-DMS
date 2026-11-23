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
  # LocalSend / OpenMarket 写死路径，若 AppImage 被移动/删除需同步改此文件。
  # ============================================================

  home.packages = [folo];

  xdg.desktopEntries = {
    folo = {
      name = "Folo";
      comment = "Follow everything in one place";
      # %u 必须保留：浏览器把 folo://auth?token=... 交回来时，URL 作为参数传给包装脚本
      exec = "folo %u";
      # OAuth 回调走自定义 scheme（Folo 会用 setAsDefaultProtocolClient 注册 folo://、follow://）。
      # 桌面项里不声明 MimeType 时，GLib/Chrome 可能认为没有可用 handler，登录就回不到应用。
      mimeType = ["x-scheme-handler/folo" "x-scheme-handler/follow"];
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

    openmarket = {
      name = "OpenMarket";
      comment = "Desktop shell for the OpenMarket chart";
      # --no-sandbox 与 AppImage 自带 desktop 的 Exec 一致（AppRun 也会自动补）
      exec = "appimage-run ${home}/Documents/OpenMarket-linux-x86_64.AppImage --no-sandbox %u";
      # 自定义 scheme：点 openmarket:// 链接时回到应用
      mimeType = ["x-scheme-handler/openmarket"];
      icon = "applications-office";
      categories = ["Finance"];
      terminal = false;
      type = "Application";
    };

    wickline = {
      name = "Wickline";
      comment = "Free open-source charting: crypto, stocks, forex, futures";
      # 写死版本号（v0.1.7），升级时改此路径；与 OpenMarket 一样放 ~/Documents
      exec = "appimage-run ${home}/Documents/Wickline-Linux-0.1.7.AppImage --no-sandbox %u";
      icon = "utilities-system-monitor";
      categories = ["Office" "Finance"];
      terminal = false;
      type = "Application";
    };
  };
}
