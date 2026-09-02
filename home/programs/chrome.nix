{
  pkgs,
  lib,
  ...
}: {
  # ⚠️ nixpkgs 的 google-chrome wrapper 不读取 chrome-flags.conf（那是 Arch 脚本惯例），
  # Wayland/GPU 启动参数必须经 commandLineArgs 注入（原 conf 内容迁移于此）
  home = {
    packages = [
      # Google Chrome（闭源）：启动参数（原 chrome-flags.conf 内容迁移于此）
      (pkgs.google-chrome.override {
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
    ];

    # 环境变量：视频加速 / Wayland 支持
    sessionVariables = {
      LIBVA_DRIVER_NAME = "radeonsi";
      LIBVA_MESSAGING_LEVEL = "1";
      LIBGL_ALWAYS_SOFTWARE = "0";
      ENABLE_VAAPI = "1";
      ENABLE_VDPAU = "1";
      VAAPI_DISABLE_ENCODER_CHECKING = "1";
      EGL_PLATFORM = "wayland";
    };
  };
}
