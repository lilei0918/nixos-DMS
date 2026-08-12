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

      lxgw-wenkai # 霞鹜文楷（备选）

      # =========================
      # 等宽 / Nerd Font
      # =========================
      # Maple Mono NF CN 在 nixpkgs(f13ff45) 不可用，用 JetBrainsMono Nerd Font

      nerd-fonts.jetbrains-mono

      # =========================
      # Emoji（Twemoji 主用，Noto 兜底）
      # =========================

      twemoji-color-font

      noto-fonts-color-emoji

      # 通用兜底
      noto-fonts
    ];

    fontconfig = {
      enable = true;

      # =========================
      # 默认字体（参照 ryan4yin：中文优先思源黑体/宋体）
      # fontconfig 按列表顺序、逐字符取第一个含字形的字体
      # =========================

      defaultFonts = {
        # 衬线（阅读 / 文档）：中文宋体优先
        serif = [
          "Source Han Serif SC"

          "Source Han Serif TC"

          "Source Serif 4"
        ];

        # 无衬线（UI / 网页）：中文黑体优先（≈ Noto Sans CJK 观感）
        sansSerif = [
          "Source Han Sans SC"

          "Source Han Sans TC"

          "Source Sans 3"

          "LXGW WenKai Screen" # 楷体兜底，正常不会命中
        ];

        # 等宽（终端 / 代码）
        monospace = [
          "JetBrainsMono Nerd Font"

          "Source Han Mono SC"

          "Source Han Mono TC"
        ];

        # Emoji：Twemoji 优先
        emoji = [
          "Twemoji"

          "Noto Color Emoji"
        ];
      };

      # =========================
      # 渲染参数（参照 ryan4yin）
      # =========================

      antialias = true; # 抗锯齿

      hinting = {
        enable = true;

        style = "slight"; # hintslight
      };

      subpixel = {
        rgba = "rgb"; # IPS 屏 rgb 子像素排列

        lcdfilter = "default"; # lcddefault
      };

      # 参照 ryan4yin 的 web-ui-fonts.conf + source-han-for-noto-cjk.conf
      # （映射目标改为实际安装的分地区子家族名）
      # ⚠️ localConf 是原样写入 /etc/fonts/local.conf，必须是完整的
      # fontconfig 文档：外层要有 <fontconfig> 根元素
      localConf = ''
        <fontconfig>
        <!-- 渲染：关 autohint、禁 embeddedbitmap（Twemoji 除外） -->
        <match target="font">
          <edit mode="assign" name="autohint"><bool>false</bool></edit>
        </match>
        <match target="font">
          <test name="family" compare="not_eq"><string>Twemoji</string></test>
          <test name="family" compare="not_eq"><string>Noto Color Emoji</string></test>
          <edit name="embeddedbitmap" mode="assign"><bool>false</bool></edit>
        </match>

        <!-- CSS ui-* / 系统字体名 → 标准泛型（GitHub 代码块等用 ui-monospace） -->
        <match target="pattern">
          <test qual="any" name="family"><string>ui-monospace</string></test>
          <edit name="family" mode="assign" binding="same"><string>monospace</string></edit>
        </match>
        <match target="pattern">
          <test qual="any" name="family"><string>ui-sans-serif</string></test>
          <edit name="family" mode="assign" binding="same"><string>sans-serif</string></edit>
        </match>
        <match target="pattern">
          <test qual="any" name="family"><string>ui-serif</string></test>
          <edit name="family" mode="assign" binding="same"><string>serif</string></edit>
        </match>
        <match target="pattern">
          <test qual="any" name="family"><string>-apple-system</string></test>
          <edit name="family" mode="assign" binding="same"><string>sans-serif</string></edit>
        </match>

        <!-- Noto CJK 名 → 思源（装的是分地区子家族；无 JP，JP 落到 SC） -->
        <match target="pattern">
          <test qual="any" name="family"><string>Noto Sans CJK SC</string></test>
          <edit name="family" mode="assign" binding="same"><string>Source Han Sans SC</string></edit>
        </match>
        <match target="pattern">
          <test qual="any" name="family"><string>Noto Sans CJK TC</string></test>
          <edit name="family" mode="assign" binding="same"><string>Source Han Sans TC</string></edit>
        </match>
        <match target="pattern">
          <test qual="any" name="family"><string>Noto Sans CJK HK</string></test>
          <edit name="family" mode="assign" binding="same"><string>Source Han Sans HC</string></edit>
        </match>
        <match target="pattern">
          <test qual="any" name="family"><string>Noto Sans CJK JP</string></test>
          <edit name="family" mode="assign" binding="same"><string>Source Han Sans SC</string></edit>
        </match>
        <match target="pattern">
          <test qual="any" name="family"><string>Noto Sans CJK KR</string></test>
          <edit name="family" mode="assign" binding="same"><string>Source Han Sans K</string></edit>
        </match>
        <match target="pattern">
          <test qual="any" name="family"><string>Noto Serif CJK SC</string></test>
          <edit name="family" mode="assign" binding="same"><string>Source Han Serif SC</string></edit>
        </match>
        <match target="pattern">
          <test qual="any" name="family"><string>Noto Serif CJK TC</string></test>
          <edit name="family" mode="assign" binding="same"><string>Source Han Serif TC</string></edit>
        </match>
        <match target="pattern">
          <test qual="any" name="family"><string>Noto Serif CJK HK</string></test>
          <edit name="family" mode="assign" binding="same"><string>Source Han Serif HC</string></edit>
        </match>
        <match target="pattern">
          <test qual="any" name="family"><string>Noto Serif CJK JP</string></test>
          <edit name="family" mode="assign" binding="same"><string>Source Han Serif SC</string></edit>
        </match>
        <match target="pattern">
          <test qual="any" name="family"><string>Noto Serif CJK KR</string></test>
          <edit name="family" mode="assign" binding="same"><string>Source Han Serif K</string></edit>
        </match>
        </fontconfig>
      '';
    };
  };
}
