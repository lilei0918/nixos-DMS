{pkgs, ...}: {
  fonts = {
    # 关闭默认字体包（由下面 packages 完全接管）
    enableDefaultPackages = false;

    # 开启 fontconfig
    fontDir.enable = true;

    packages = with pkgs; [
      # =========================
      # 西文（Inter 主打 UI，Source Serif 阅读）
      # =========================

      inter # Inter（无衬线 UI，风格接近 SF Pro）

      source-serif # Source Serif 4（衬线阅读）

      # =========================
      # 中文（思源黑体/宋体）
      # =========================

      source-han-serif # 思源宋体（SC/TC）

      source-han-sans # 思源黑体（SC/TC）

      source-han-mono # 思源等宽（SC/TC）

      # =========================
      # 等宽 / Nerd Font
      # =========================
      # Maple Mono NF CN 在当时 nixpkgs(f13ff45) 不可用，用 JetBrainsMono Nerd Font

      nerd-fonts.jetbrains-mono

      # =========================
      # Emoji（Noto Color Emoji 主用）
      # =========================

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

        # 无衬线（UI / 网页）：Inter + 思源黑体
        sansSerif = [
          "Inter"

          "Source Han Sans SC"

          "Source Han Sans TC"

          "Noto Sans"
        ];

        # 等宽（终端 / 代码）
        monospace = [
          "JetBrainsMono Nerd Font"

          "Source Han Mono SC"

          "Source Han Mono TC"
        ];

        # Emoji：Noto Color Emoji 优先
        emoji = [
          "Noto Color Emoji"
        ];
      };

      # =========================
      # 渲染参数（macOS 风格：slight hinting + 抗锯齿 + RGB 子像素）
      # macOS 观感是 smooth/soft，不是 Linux 常见的 sharp/pixel；
      # 所以不要用 full，slight 更接近。
      # =========================

      antialias = true; # 抗锯齿

      hinting = {
        enable = true;

        style = "slight"; # 比 full 更细腻、更接近 macOS
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
        <!-- 渲染：关 autohint、禁 embeddedbitmap（Noto Color Emoji 除外） -->
        <match target="font">
          <edit mode="assign" name="autohint"><bool>false</bool></edit>
        </match>
        <match target="font">
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

        <!-- Apple 系统字体名 → Inter -->
        <match target="pattern">
          <test qual="any" name="family"><string>SF Pro</string></test>
          <edit name="family" mode="assign" binding="same"><string>Inter</string></edit>
        </match>
        <match target="pattern">
          <test qual="any" name="family"><string>SF Pro Display</string></test>
          <edit name="family" mode="assign" binding="same"><string>Inter</string></edit>
        </match>
        <match target="pattern">
          <test qual="any" name="family"><string>SF Pro Text</string></test>
          <edit name="family" mode="assign" binding="same"><string>Inter</string></edit>
        </match>
        <match target="pattern">
          <test qual="any" name="family"><string>SF Mono</string></test>
          <edit name="family" mode="assign" binding="same"><string>JetBrainsMono Nerd Font</string></edit>
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
