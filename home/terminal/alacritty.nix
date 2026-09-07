{pkgs, ...}: {
  programs.alacritty = {
    enable = true;

    settings = {
      # =========================
      # 字体
      # =========================

      font = {
        normal = {
          family = "JetBrainsMono Nerd Font";
          style = "Regular";
        };

        bold = {
          family = "JetBrainsMono Nerd Font";
          style = "Bold";
        };

        italic = {
          family = "JetBrainsMono Nerd Font";
          style = "Italic";
        };

        size = 12;
      };

      # =========================
      # 窗口
      # =========================

      window = {
        opacity = 1.0;

        padding = {
          x = 8;
          y = 8;
        };

        dynamic_padding = true;

        decorations = "None";

        startup_mode = "Windowed";

        dynamic_title = true;
      };

      # =========================
      # Wayland
      # =========================

      scrolling = {
        history = 10000;
        multiplier = 3;
      };

      # =========================
      # 光标
      # =========================

      cursor = {
        style = {
          shape = "Beam";
          blinking = "Off";
        };
      };

      # =========================
      # 鼠标
      # =========================

      mouse = {
        hide_when_typing = true;
      };

      # =========================
      # Shell
      # =========================

      terminal.shell = {
        program = "${pkgs.fish}/bin/fish";
      };

      # =========================
      # Gruvbox Dark Medium
      # =========================

      colors = {
        primary = {
          background = "0x282828";
          foreground = "0xebdbb2";
        };

        cursor = {
          cursor = "0xebdbb2";
        };

        selection = {
          background = "0x504945";
          text = "0xebdbb2";
        };

        normal = {
          black = "0x282828";
          red = "0xcc241d";
          green = "0x98971a";
          yellow = "0xd79921";
          blue = "0x458588";
          magenta = "0xb16286";
          cyan = "0x689d6a";
          white = "0xa89984";
        };

        bright = {
          black = "0x928374";
          red = "0xfb4934";
          green = "0xb8bb26";
          yellow = "0xfabd2f";
          blue = "0x83a598";
          magenta = "0xd3869b";
          cyan = "0x8ec07c";
          white = "0xfbf1c7";
        };
      };

      # =========================
      # 性能
      # =========================

      general.live_config_reload = true;

      # =========================
      # 快捷键
      # =========================

      keyboard.bindings = [
        {
          key = "C";
          mods = "Super";
          action = "Copy";
        }

        {
          key = "V";
          mods = "Super";
          action = "Paste";
        }
      ];
    };
  };

  # 注：不再设置 WINIT_UNIX_BACKEND（已废弃，alacritty 自动选 Wayland）
  # 和 TERM=alacritty（全局导出会污染 ssh/其它终端的 TERM，alacritty 自行注入）。
}
