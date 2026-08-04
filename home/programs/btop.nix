_: {
  programs.btop = {
    enable = true;
    settings = {
      presets = "cpu:0:default,net:0:tty,proc:1:default";
      color_theme = "TTY";
      theme_background = false;
      update_ms = 500;
      rounded_corners = false;
    };
  };
  xdg.desktopEntries.btop = {
    name = "btop";
    comment = "A modern resource monitor";
    exec = "ghostty -e btop";
    icon = "utilities-system-monitor";
    terminal = false;
    type = "Application";
    categories = ["System" "Monitor"];
  };
}
