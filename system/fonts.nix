{
  lib,
  pkgs,
  ...
}: {
  fonts = {
    # 开启 fontconfig
    fontDir.enable = true;

    packages = with pkgs;
      [
        # =========================
        # 中文字体
        # =========================

        # 中文 UI / 网页
        noto-fonts-cjk-sans

        # 中文阅读 / PDF
        noto-fonts-cjk-serif

        # =========================
        # Emoji
        # =========================

        noto-fonts-color-emoji

        # =========================
        # 英文 UI
        # =========================

        inter

        # =========================
        # 编程字体
        # =========================

        fira-code

        # =========================
        # Nerd Font
        # =========================

        # 终端 / Starship / VSCodium
        nerd-fonts.jetbrains-mono

        # =========================
        # 通用字体
        # =========================

        noto-fonts
      ]
      # Material Symbols
      ++ lib.optionals (pkgs ? material-symbols) [
        pkgs.material-symbols
      ]
      ++ lib.optionals
      (!(pkgs ? material-symbols) && (pkgs ? material-design-icons))
      [
        pkgs.material-design-icons
      ];

    fontconfig = {
      enable = true;

      # =========================
      # 默认字体 fallback
      # =========================

      defaultFonts = {
        # GTK / 浏览器 / UI

        sansSerif = [
          "Noto Sans CJK SC"

          "Inter"

          "Noto Sans"
        ];

        # 阅读 / PDF

        serif = [
          "Noto Serif CJK SC"

          "Noto Serif"
        ];

        # Terminal / Coding

        monospace = [
          "JetBrainsMono Nerd Font"

          "Noto Sans Mono CJK SC"
        ];

        # Emoji

        emoji = [
          "Noto Color Emoji"
        ];
      };

      # =========================
      # 字体渲染
      # =========================

      antialias = true;

      hinting = {
        enable = true;

        style = "slight";
      };

      # Wayland 推荐
      # 避免外接屏幕颜色边缘

      subpixel = {
        rgba = "none";

        lcdfilter = "default";
      };
    };
  };
}
