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
      # Monokai Pro
      # =========================

      colors = {
        primary = {
          background = "0x2d2a2e";
          foreground = "0xfcfcfa";
        };

        cursor = {
          cursor = "0xc1c0c0";
        };

        selection = {
          background = "0x5b595c";
          text = "0xfcfcfa";
        };

        normal = {
          black = "0x2d2a2e";
          red = "0xff6188";
          green = "0xa9dc76";
          yellow = "0xffd866";
          blue = "0xfc9867";
          magenta = "0xab9df2";
          cyan = "0x78dce8";
          white = "0xfcfcfa";
        };

        bright = {
          black = "0x727072";
          red = "0xff6188";
          green = "0xa9dc76";
          yellow = "0xffd866";
          blue = "0xfc9867";
          magenta = "0xab9df2";
          cyan = "0x78dce8";
          white = "0xfcfcfa";
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
          mods = "Control|Shift";
          action = "Copy";
        }

        {
          key = "V";
          mods = "Control|Shift";
          action = "Paste";
        }
      ];
    };
  };

  # 注：不再设置 WINIT_UNIX_BACKEND（已废弃，alacritty 自动选 Wayland）
  # 和 TERM=alacritty（全局导出会污染 ssh/其它终端的 TERM，alacritty 自行注入）。
}
