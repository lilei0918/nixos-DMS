{pkgs, ...}: {
  programs.ghostty = {
    enable = true;

    # =============================
    # Shell
    # =============================

    settings = {
      # =============================
      # Theme
      # =============================

      theme = "monokai-pro";

      # =============================
      # Font
      # =============================

      font-family = [
        "JetBrainsMono Nerd Font"
      ];

      font-size = 14;

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
