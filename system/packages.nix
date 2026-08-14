{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # ─────────────────────────────
    # 🧰 系统基础工具
    # ─────────────────────────────

    wget
    curl

    git
    lazygit

    nh

    jq
    socat

    tree

    ripgrep
    fd
    bat
    eza

    # ─────────────────────────────
    # 🖥️ Terminal
    # ─────────────────────────────

    alacritty

    tmux

    starship

    fzf

    zoxide

    direnv

    # ─────────────────────────────
    # 📦 压缩 / 解压
    # ─────────────────────────────

    zip
    unzip

    p7zip

    rar

    dtrx

    # ─────────────────────────────
    # 💻 Nix 开发工具
    # ─────────────────────────────

    nil

    alejandra

    statix

    deadnix

    nix-tree

    nix-output-monitor

    sops

    age

    # ─────────────────────────────
    # 🔨 编译工具
    # ─────────────────────────────

    gcc

    gnumake

    # ─────────────────────────────
    # 🖥️ Wayland / Niri
    # ─────────────────────────────

    xwayland

    xwayland-satellite

    wl-clipboard

    # ─────────────────────────────
    # 🔍 硬件检测
    # ─────────────────────────────

    pciutils

    ddcutil

    # ─────────────────────────────
    # 💾 文件系统
    # ─────────────────────────────

    btrfs-progs

    ntfs3g

    # ─────────────────────────────
    # 🌐 网络兼容
    # ─────────────────────────────

    wsdd

    # ─────────────────────────────
    # 🔐 Secret
    # ─────────────────────────────

    libsecret

    # ─────────────────────────────
    # 📱 Android 调试（adb）
    # ─────────────────────────────

    android-tools

    # ─────────────────────────────
    # 📦 AppImage
    # ─────────────────────────────

    # 运行 AppImage 文件：appimage-run xxx.AppImage
    # 但部分 AppImage（如 longbridge）依赖系统库（webkit），沙箱里没有。
    # 见下方 programs.nix-ld：解压后直接用 nix-ld 加载器运行即可找到这些库。
    appimage-run

    # ─────────────────────────────
    # 🎧 系统控制
    # ─────────────────────────────

    playerctl

    brightnessctl

    libnotify

    # ─────────────────────────────
    # 编辑器
    # ─────────────────────────────

    vim

    gnome-text-editor
  ];

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

      nss

      nspr

      at-spi2-core

      alsa-lib

      cups

      libdrm

      mesa

      libgbm # libgbm.so.1（mesa 不直接提供该 soname）

      libxkbcommon

      libpulseaudio

      xorg.libX11

      xorg.libXcomposite

      xorg.libXdamage

      xorg.libXext

      xorg.libXfixes

      xorg.libXrandr

      xorg.libxcb

      xorg.libXcursor

      xorg.libXi

      xorg.libXrender

      xorg.libXtst

      # Qt xcb 平台插件所需
      xcbutilwm # libxcb-icccm

      xcbutilimage # libxcb-image

      xcbutilkeysyms # libxcb-keysyms

      xcbutilrenderutil # libxcb-render-util

      xorg.libSM

      xorg.libICE

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
