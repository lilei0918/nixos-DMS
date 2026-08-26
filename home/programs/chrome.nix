_: {
  # ⚠️ nixpkgs 的 google-chrome wrapper 不读取 chrome-flags.conf（那是 Arch 脚本惯例），
  # 启动参数统一在 hosts/legion/packages.nix 经 commandLineArgs 注入。
  # 这里只保留环境变量：视频加速 / Wayland 支持
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
