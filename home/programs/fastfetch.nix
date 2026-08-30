_: {
  programs.fastfetch = {
    enable = true;

    settings = {
      logo = {
        # alacritty 不支持 kitty 图形协议（kitty-direct 会静默不显示），
        # 用 auto 让 fastfetch 自动选择终端支持的渲染方式（ghostty 下仍会用 kitty）。
        # 若 auto 在 alacritty 下仍无 logo，可改 "chafa"（块字符渲染，任何终端可用）。
        type = "auto";
        source = ../../assets/icons/logo.png;
        # 显式限制宽度（字符列数）：不设时 fastfetch 默认取终端宽度一半，
        # 80 列终端下 logo 占 40 列会把右侧信息挤掉。20x20 方形保持宽高比。
        width = 20;
        height = 20;
        padding = {
          top = 8;
          bottom = 8;
          right = 5;
          left = 5;
        };
      };

      display = {
        separator = " -> ";
      };

      modules = [
        "break"

        {
          type = "custom";
          format = "╭────────────────────── Hardware ──────────────────────╮";
          outputColor = "red";
        }

        {
          type = "title";
          key = " PC";
          keyColor = "green";
          format = "{user-name-colored} on {host-name-colored}";
        }

        {
          type = "cpu";
          key = "│ ├ CPU";
          showPeCoreCount = true;
          format = "{name} {freq-max}";
          keyColor = "green";
        }

        {
          type = "gpu";
          key = "│ ├ GPU";
          keyColor = "green";
          format = "{vendor} {name}";
        }

        {
          type = "disk";
          key = "│ ├ Disk";
          keyColor = "green";
        }

        {
          type = "memory";
          key = "└ └ Memory";
          keyColor = "green";
        }

        {
          type = "custom";
          format = "╰──────────────────────────────────────────────────────╯";
          outputColor = "red";
        }

        "break"

        {
          type = "custom";
          format = "╭────────────────────── Software ──────────────────────╮";
          outputColor = "red";
        }

        {
          type = "os";
          key = " OS";
          keyColor = "yellow";
          # TODO: use the pretty name
          # format = "{pretty-name} {version-id} {codename}";
          format = "NixOS {version-id} {codename}";
        }

        {
          type = "kernel";
          key = "│ ├ Kernel";
          keyColor = "yellow";
        }

        {
          type = "shell";
          key = "│ ├ Shell";
          keyColor = "yellow";
          format = "{1}";
        }

        {
          type = "packages";
          key = "│ ├ Packages";
          keyColor = "yellow";
        }

        {
          type = "command";
          key = "│ ├ OS Age";
          keyColor = "yellow";
          text = ''
            birth_install=$(stat -c %W /); \
            current=$(date +%s); \
            time_progression=$((current - birth_install)); \
            days_difference=$((time_progression / 86400)); \
            echo $days_difference days
          '';
        }

        {
          type = "uptime";
          key = "└ └ Uptime";
          keyColor = "yellow";
        }

        "break"

        {
          type = "wm";
          key = " Compositor";
          keyColor = "blue";
          format = "{1}";
        }

        {
          type = "lm";
          key = "│ ├ Login";
          keyColor = "blue";
          format = "{1}";
        }

        {
          type = "terminal";
          key = "│ ├ Terminal";
          keyColor = "blue";
          format = "{1}";
        }

        {
          type = "terminalfont";
          key = "│ ├ Font";
          keyColor = "blue";
          format = "{name}";
        }

        {
          type = "icons";
          key = "│ ├ Icons";
          keyColor = "blue";
        }

        {
          type = "custom";
          key = "└ └ Theme";
          keyColor = "blue";
          format = "Stylix";
        }

        {
          type = "custom";
          format = "╰──────────────────────────────────────────────────────╯";
          outputColor = "red";
        }

        {
          type = "colors";
          paddingLeft = 20;
          symbol = "circle";
        }

        "break"
      ];
    };
  };
}
