{
  pkgs,
  lib,
  ...
}:
with pkgs; [
  # ─────────────────────────────
  # 🌐 浏览器
  # ─────────────────────────────

  # Google Chrome（闭源）：nixpkgs wrapper 不读 chrome-flags.conf，
  # Wayland/GPU 参数必须经 commandLineArgs 注入（原 conf 内容迁移于此）
  (google-chrome.override {
    commandLineArgs = lib.concatStringsSep " " [
      "--ozone-platform=wayland"
      # 原生 Wayland 输入法（text-input-v3）：不加此参数 Chrome 无 IME 通道，中文输入法打不出字
      "--enable-wayland-ime"
      "--wayland-text-input-version=3"
      "--enable-features=UseOzonePlatform,WebUIDarkMode,DesktopPWAsNotificationIconAndTitle"
      "--enable-native-notifications"
      # 显卡硬件加速
      "--use-gl=desktop"
      "--ignore-gpu-blocklist"
      "--enable-gpu-rasterization"
      "--enable-zero-copy"
      "--enable-vulkan"
      "--disable-gpu-driver-bug-workarounds"
      "--enable-hardware-overlays"
      "--enable-accelerated-video-decode"
      "--enable-accelerated-video-encode"
      "--enable-oop-rasterization"
      "--enable-raw-draw"
      "--enable-webgl-developer-extensions"
      "--enable-accelerated-2d-canvas"
      "--enable-gpu-compositing"
      "--enable-smooth-scrolling"
      "--enable-media-router"
      # 修复默认行为
      "--no-default-browser-check"
      "--no-pings"
    ];
  })

  # ─────────────────────────────
  # 📄 办公 / 阅读
  # ─────────────────────────────

  libreoffice # LibreOffice 办公套件（文档、表格、演示）
  foliate # Epub 电子书阅读器（简洁、支持多格式）
  loupe # GNOME 图片查看器（简单、快速）
  zathura # 轻量级 PDF/文档查看器（Vim 风格快捷键）
  zettlr # 学术级 Markdown 编辑器
  #thunderbird
  papers
  readest

  # ─────────────────────────────
  # 💰 金融
  # ─────────────────────────────

  #tradingview # TradingView 金融图表分析工具（桌面客户端）

  # ─────────────────────────────
  # 💬 通讯
  # ─────────────────────────────

  qq # 腾讯 QQ 客户端（Linux 版）
  telegram-desktop

  # ─────────────────────────────
  # 🎨 桌面配置
  # ─────────────────────────────

  nwg-look # GTK 设置管理工具（主题、字体、图标）
  apple-cursor # macOS 风格光标主题
  waypaper # Wallpaper 管理工具（Wayland 下设置壁纸）
  dconf-editor # Dconf 配置编辑器（GNOME 底层设置）
  matugen # 动态主题生成器（根据壁纸生成配色方案）

  # Qt

  qt6Packages.qt6ct # Qt6 配置工具（主题、字体、界面设置）

  # ─────────────────────────────
  # 🗂️ 文件管理
  # ─────────────────────────────

  file-roller # 归档管理器（压缩/解压 GUI 前端）
  xz
  localsend # 局域网文件传输工具（类似 AirDrop）
  duf

  # ─────────────────────────────
  # 🔊 音频 / 视频
  # ─────────────────────────────

  pavucontrol # PulseAudio 音量控制（图形化混音器）
  mpv # 媒体播放器（命令行 + 图形，支持所有常见格式）
  gpu-screen-recorder # GPU 加速屏幕录制工具（支持 Wayland）
  blanket # 白噪音 / 背景音播放器（专注辅助）

  # ─────────────────────────────
  # 🎵 音乐
  # ─────────────────────────────

  #spicetify-cli # Spotify 客户端主题/插件命令行工具（需配合 Spotify）

  # ─────────────────────────────
  # 📝 笔记
  # ─────────────────────────────

  siyuan # 思源笔记（本地 Markdown 笔记，支持双向链接）

  marktext

  # ─────────────────────────────
  # 🖼️ 图片
  # ─────────────────────────────

  #imagemagick # 命令行图像处理工具（转换、编辑、生成）
]
