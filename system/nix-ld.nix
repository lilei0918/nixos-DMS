{pkgs, ...}: {
  ############################################
  # 兼容动态链接器（nix-ld）
  # 让非 Nix 二进制（AppImage 解压、.deb 解压的程序等）通过 nix-ld 加载器
  # 找到系统库。以下为 Qt/CEF 应用（富途 futu）运行所需的系统库。
  # 需跑别的非 Nix 软件缺库时，按报错往里补。
  ############################################

  programs.nix-ld = {
    enable = true;

    libraries = with pkgs; [
      # Electron / CEF 应用（富途 futu）所需系统库
      gtk3

      glib

      pango # libpango（GTK 渲染，nix-ld 不自动带传递依赖）

      cairo # libcairo

      harfbuzz # libharfbuzz.so.0

      atk # libatk-1.0.so.0

      gdk-pixbuf # libgdk_pixbuf-2.0.so.0

      fontconfig # libfontconfig.so.1

      freetype # libfreetype.so.6

      libpng # libpng16.so.16

      libjpeg # libjpeg.so.62（libjpeg-turbo）

      libjpeg8 # libjpeg.so.8（jpeg-8 ABI，libmpv 等旧库需要；libjpeg 默认构建只提供 .62）

      libtiff # libtiff.so.6

      pcre2 # libpcre2-8.so.0（glib 依赖）

      libffi # libffi.so.8（glib 依赖）

      brotli # libbrotlidec.so.1（fontconfig/freetype 依赖）

      graphite2 # libgraphite2.so.0（harfbuzz 依赖）

      # 媒体栈（gstreamer/mpv）传递依赖
      libbsd # libbsd.so.0

      libmd # libmd.so.1（libbsd 依赖）

      libcap # libcap.so.2

      libgcrypt # libgcrypt.so.20

      libgpg-error # libgpg-error.so.0

      lz4 # liblz4.so.1

      librsvg # librsvg-2.so.2（AppImage 自带的新版缺少 rsvg_handle_get_pixbuf_and_error 符号）

      nss

      nspr

      at-spi2-core

      alsa-lib

      cups

      libdrm

      mesa

      libepoxy # libepoxy.so.0（GTK 渲染 / GL 派发）

      libgbm # libgbm.so.1（mesa 不直接提供该 soname）

      libxkbcommon

      libpulseaudio

      libx11

      libxcomposite

      libxdamage

      libxext

      libxfixes

      libxrandr

      libxcb

      libxcursor

      libxi

      libxrender

      libxtst

      # Qt xcb 平台插件所需
      xcbutilwm # libxcb-icccm

      xcbutilimage # libxcb-image

      xcbutilkeysyms # libxcb-keysyms

      xcbutilrenderutil # libxcb-render-util

      libsm

      libice

      dbus

      expat

      # 通用基础
      stdenv.cc.cc.lib

      zlib

      curl

      openssl

      icu

      libGL
    ];
  };
}
