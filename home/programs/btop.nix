_: {
  programs.btop = {
    enable = true;
    settings = {
      presets = "cpu:0:default,net:0:tty,proc:1:default";
      color_theme = "gruvbox_dark";
      theme_background = false;
      update_ms = 500;
      rounded_corners = false;
    };
  };
  xdg.desktopEntries.btop = {
    name = "btop";
    comment = "A modern resource monitor";
    # --title=btop：固定窗口标题，供 niri windowrules.kdl 匹配（btop 半屏宽）
    exec = "ghostty --title=btop -e btop";
    icon = "utilities-system-monitor";
    terminal = false;
    type = "Application";
    categories = ["System" "Monitor"];
  };
}
