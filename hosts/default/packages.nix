{ pkgs, ... }:
with pkgs;
[
  # ─────────────────────────────────────────────────────
  # 📦 应用程序（GUI）
  # ─────────────────────────────────────────────────────
  file-roller
  google-chrome
  foliate
  # thunderbird
  # amberol
  # eog
  loupe
  zathura
  tradingview
  qq
  libreoffice
  # apostrophe

  # errands
  # authenticator
  alacritty
  wl-clip-persist

  # ─────────────────────────────────────────────────────
  # 🖥️ 桌面环境与设置工具
  # ─────────────────────────────────────────────────────
  nwg-look
  polkit_gnome
  dconf-editor
  wl-clipboard
  brightnessctl
  libnotify

  matugen
  libsForQt5.qt5ct
  qt6Packages.qt6ct
  glib
  #libsForQt5.qt5.qtwebsockets

  # ─────────────────────────────────────────────────────
  # 🔧 实用工具
  # ─────────────────────────────────────────────────────
  jq
  socat
  tree
  rar
  unzip
  udisks2
  pywalfox-native
  imagemagick
  # awww
  micro
  mousepad
  # amdvlk
  # droidcam
  siyuan

  # ─────────────────────────────────────────────────────
  # 🎛️ 音视频相关
  # ─────────────────────────────────────────────────────
  gpu-screen-recorder
  mpv
  pavucontrol
  bluez
  bluez-tools

  blanket
  #zeroad

  # ─────────────────────────────────────────────────────
  # 🧰 命令行工具 / TUI
  # ─────────────────────────────────────────────────────
  btop
  #rclone

  # ─────────────────────────────────────────────────────
  # 💻 开发工具
  # ─────────────────────────────────────────────────────
  gcc
  gh
  vim
  nil
  alejandra
  # feh
  # rustup
  # nixfmt-rfc-style
  # nixpkgs-fmt
  # black

  # ─────────────────────────────────────────────────────
  # 🪟 Niri 相关组件
  # ─────────────────────────────────────────────────────
  xwayland-satellite
]
