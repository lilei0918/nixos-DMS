{
  lib,
  config,
  pkgs,
  ...
}: let
  apps = import ./applications.nix {inherit pkgs;};
  ghostty = lib.getExe' pkgs.ghostty "ghostty"; # 自动获取正确路径
in {
  binds = with config.lib.niri.actions; let
    ghostty = lib.getExe' pkgs.ghostty "ghostty";
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

    # 📸 截图（使用 grim + slurp）
    "print".action = spawn "grim" ["-g" "$(slurp)" "-" "|" "wl-copy"];
    "alt+print".action = spawn "grim" ["-g" "$(slurp -w)" "-" "|" "wl-copy"];
    "ctrl+print".action = spawn "grim" ["-" "|" "wl-copy"];
    "mod+p".action = spawn "grim" ["-g" "$(slurp)" "-" "|" "wl-copy"]; # 自定义截图
  };
}
