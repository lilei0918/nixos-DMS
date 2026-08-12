{pkgs, ...}: {
  fonts = {
    # 关闭默认字体包（由下面 packages 完全接管）
    enableDefaultPackages = false;

    # 开启 fontconfig
    fontDir.enable = true;

    packages = with pkgs; [
      # =========================
      # 西文（Source 系列）
      # =========================

      source-serif # Source Serif 4（衬线）

      source-sans # Source Sans 3（无衬线）

      # =========================
      # 中文（思源黑体/宋体 + 霞鹜文楷）
      # =========================

      source-han-serif # 思源宋体（SC/TC）

      source-han-sans # 思源黑体（SC/TC）

      source-han-mono # 思源等宽（SC/TC）

      lxgw-wenkai # 霞鹜文楷（含 Screen 屏幕版）

      # =========================
      # 等宽 / Nerd Font
      # =========================
      # Maple Mono NF CN 在 nixpkgs(f13ff45) 不可用，
      # 等宽主字体用 JetBrainsMono Nerd Font

      nerd-fonts.jetbrains-mono

      # =========================
      # Emoji
      # =========================

      noto-fonts-color-emoji

      # 通用兜底
      noto-fonts
    ];

    fontconfig = {
      enable = true;

      # =========================
      # 默认字体 fallback
      # =========================

      defaultFonts = {
        # 衬线（阅读 / 印刷）
        serif = [
          "Source Serif 4"

          "Source Han Serif SC"

          "Source Han Serif TC"
        ];

        # 无衬线（UI / 屏幕显示）
        sansSerif = [
          "Source Sans 3"

          "LXGW WenKai Screen"

          "Source Han Sans SC"

          "Source Han Sans TC"
        ];

        # 等宽（终端 / 代码）
        monospace = [
          "JetBrainsMono Nerd Font"

          "Source Han Mono SC"

          "Source Han Mono TC"
        ];

        # Emoji
        emoji = ["Noto Color Emoji"];
      };

      # 抗锯齿
      antialias = true;

      # 高分屏无需字体微调
      hinting.enable = false;

      # IPS 屏 rgb 子像素排列（参照 ryan4yin 配置；
      # 若外接屏出现彩色描边，改回 rgba = "none"）
      subpixel.rgba = "rgb";
    };
  };
}
