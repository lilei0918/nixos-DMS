{
  lib,
  config,
  pkgs,
  ...
}: {
  binds = with config.lib.niri.actions; let
    google-chrome = lib.getExe' pkgs.google-chrome "google-chrome-stable";
    thunar = lib.getExe' pkgs.thunar "thunar";
    walker = lib.getExe' pkgs.walker "walker"; # ← fuzzel 改为 walker
  in {
    # 🪟 窗口管理
    "super+q".action = close-window;
    "super+f".action = fullscreen-window; # 全屏窗口（Mod+F）
    "super+shift+f".action = maximize-column; # 最大化列（Mod+Shift+F）
    "super+t".action = toggle-window-floating; # 切换浮动（Mod+T）

    # 居中当前列
    "super+c".action = center-column;

    # 🔄 工作区切换
    "super+tab".action = focus-workspace-previous;

    # 📐 列宽调整
    "super+1".action = set-column-width "25%";
    "super+2".action = set-column-width "50%";
    "super+3".action = set-column-width "75%";
    "super+4".action = set-column-width "100%";

    # 🖥️ 启动程序
    "super+shift+return".action = spawn "ghostty";
    "super+return".action = spawn "alacritty";
    "super+d".action = spawn walker []; # 应用启动器
    "super+e".action = spawn thunar []; # 文件管理器
    "super+b".action = spawn google-chrome []; # 浏览器

    # 📸 截图（使用 niri 内置截图，保存到 ~/Pictures/Screenshots/）
    # niri 内置截图 UI：Enter/Space 保存到 screenshot-path，Ctrl+Enter 复制到剪贴板
    # 注意：config.lib.niri.actions 是 niri-flake 缓存的旧清单，不含 screenshot*，
    # 必须用 action.<动作名> 直接写 KDL 动作名（niri v25.08 支持）
    "Print".action.screenshot = {};
    "Alt+Print".action.screenshot-window = {};
    "Ctrl+Print".action.screenshot-screen = {};
    "Mod+P".action.screenshot = {};
  };
}
