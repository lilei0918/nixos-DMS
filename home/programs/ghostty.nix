{
  pkgs,
  host,
  ...
}: {
  programs.ghostty = {
    enable = true;

    # 主配置
    settings = {
      theme = "monokai-pro"; # 使用上面定义的主题

      font-family = [
        "JetBrainsMono Nerd Font"
        "Noto Sans CJK SC"
      ];
      font-size = 14;

      bold-is-bright = false;
      selection-invert-fg-bg = true;

      # Theme/display
      background-opacity = 1;

      cursor-style = "bar";
      cursor-style-blink = false;
      adjust-cursor-thickness = 1;

      resize-overlay = "never";
      copy-on-select = false;
      confirm-close-surface = false;
      mouse-hide-while-typing = true;

      window-theme = "ghostty";
      # window-padding-x = 4;
      # window-padding-y = 6;
      window-padding-balance = true;
      window-padding-color = "background";
      window-inherit-working-directory = true;
      window-inherit-font-size = true;
      window-decoration = false;

      gtk-single-instance = false;
      gtk-tabs-location = "bottom";

      clipboard-paste-protection = false;
    };

    # 自定义主题文件：~/.config/ghostty/themes/monokai-pro
    themes.monokai-pro = {
      background = "2d2a2e";
      foreground = "fcfcfa";
      cursor-color = "c1c0c0";
      selection-background = "5b595c";
      selection-foreground = "fcfcfa";

      palette = [
        "0=#2d2a2e"
        "1=#ff6188"
        "2=#a9dc76"
        "3=#ffd866"
        "4=#fc9867"
        "5=#ab9df2"
        "6=#78dce8"
        "7=#fcfcfa"
        "8=#727072"
        "9=#ff6188"
        "10=#a9dc76"
        "11=#ffd866"
        "12=#fc9867"
        "13=#ab9df2"
        "14=#78dce8"
        "15=#fcfcfa"
      ];
    };
  };
}
