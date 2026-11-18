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
    # --class=btop：把 Wayland app-id 设为 "btop"，供 niri windowrules.kdl 匹配
    # （btop 平铺半屏宽）。不用 ghostty：它无法自定义 Wayland app-id。
    exec = "alacritty --class btop -e btop";
    icon = "utilities-system-monitor";
    terminal = false;
    type = "Application";
    categories = ["System" "Monitor"];
  };
}
