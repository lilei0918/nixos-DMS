_: {
  # fastfetch 极简主题（无 logo）
  # 来源: https://github.com/m3tozz/FastCat/tree/main/Small-Themes/Simple/fastfetch/config.jsonc
  programs.fastfetch = {
    enable = true;

    settings = {
      logo = null;

      display.separator = " ⌲ ";

      modules = [
        {
          type = "host";
          key = "  ";
          keyColor = "38;2;245;190;150";
        }

        {
          type = "os";
          key = "  ";
          keyColor = "38;2;245;190;150";
        }

        {
          type = "kernel";
          key = "  ";
          keyColor = "38;2;245;190;150";
        }

        {
          type = "uptime";
          key = "  ";
          keyColor = "38;2;245;190;150";
        }

        {
          type = "packages";
          key = "  ";
          keyColor = "38;2;245;190;150";
        }

        {
          type = "cpu";
          key = " 󰻠 ";
          keyColor = "38;2;190;170;220";
        }

        {
          type = "memory";
          key = "  ";
          keyColor = "38;2;190;170;220";
        }

        {
          type = "gpu";
          key = " 󰍹 ";
          keyColor = "38;2;190;170;220";
        }

        {
          type = "disk";
          key = "  ";
          keyColor = "38;2;190;170;220";
          folders = "/";
        }

        "break"
      ];
    };
  };
}
