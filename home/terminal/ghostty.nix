_: {
  programs.ghostty = {
    enable = true;

    # =============================
    # Shell
    # =============================

    settings = {
      # =============================
      # Theme
      # =============================

      theme = "gruvbox-dark-medium";

      # =============================
      # Font
      # =============================

      font-family = [
        "JetBrainsMono Nerd Font"
      ];

      font-size = 12;

      # =============================
      # Rendering
      # =============================

      bold-is-bright = false;

      background-opacity = 1;

      # =============================
      # Cursor
      # =============================

      cursor-style = "bar";

      cursor-style-blink = false;

      adjust-cursor-thickness = 1;

      # =============================
      # Window
      # =============================

      window-decoration = false;

      window-padding-x = 8;

      window-padding-y = 8;

      window-padding-balance = true;

      window-theme = "ghostty";

      window-inherit-working-directory = true;

      window-inherit-font-size = true;

      # =============================
      # Behavior
      # =============================

      keybind = [
        "super+c=copy_to_clipboard"
        "super+v=paste_from_clipboard"
        # 摘掉 ghostty 默认的 ctrl+shift+c/v，统一走 Super
        "ctrl+shift+c=ignore"
        "ctrl+shift+v=ignore"
      ];

      resize-overlay = "never";

      copy-on-select = false;

      confirm-close-surface = false;

      mouse-hide-while-typing = true;

      clipboard-paste-protection = false;

      # =============================
      # GTK
      # =============================

      gtk-single-instance = false;

      gtk-tabs-location = "bottom";
    };

    themes.gruvbox-dark-medium = {
      # Gruvbox Dark Medium（与 Zed 内置 Gruvbox Dark / Alacritty 同源配色）
      background = "282828";

      foreground = "ebdbb2";

      cursor-color = "ebdbb2";

      selection-background = "504945";

      selection-foreground = "ebdbb2";

      palette = [
        "0=#282828"

        "1=#cc241d"

        "2=#98971a"

        "3=#d79921"

        "4=#458588"

        "5=#b16286"

        "6=#689d6a"

        "7=#a89984"

        "8=#928374"

        "9=#fb4934"

        "10=#b8bb26"

        "11=#fabd2f"

        "12=#83a598"

        "13=#d3869b"

        "14=#8ec07c"

        "15=#fbf1c7"
      ];
    };
  };
}
