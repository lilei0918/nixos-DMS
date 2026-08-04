_: {
  # Google Chrome Stable 启动参数
  xdg.configFile."chromium-flags.conf".text = ''
    --ozone-platform=wayland
    --enable-features=UseOzonePlatform,WebUIDarkMode,DesktopPWAsNotificationIconAndTitle
    --enable-native-notifications

      # ✅ 显卡硬件加速
      --use-gl=desktop
      --ignore-gpu-blocklist
      --enable-gpu-rasterization
      --enable-zero-copy
      --enable-vulkan
      --disable-gpu-driver-bug-workarounds
      --enable-hardware-overlays
      --enable-accelerated-video-decode
      --enable-accelerated-video-encode
      --enable-oop-rasterization
      --enable-raw-draw
      --enable-webgl-developer-extensions
      --enable-accelerated-2d-canvas
      --enable-gpu-compositing
      --enable-smooth-scrolling
      --enable-media-router

      # ✅ 修复默认行为
      --no-default-browser-check
      --no-pings
  '';

  # 设置环境变量：视频加速 / Wayland 支持
  home.sessionVariables = {
    LIBVA_DRIVER_NAME = "radeonsi";
    LIBVA_MESSAGING_LEVEL = "1";
    LIBGL_ALWAYS_SOFTWARE = "0";
    ENABLE_VAAPI = "1";
    ENABLE_VDPAU = "1";
    VAAPI_DISABLE_ENCODER_CHECKING = "1";
    EGL_PLATFORM = "wayland";
  };
}
