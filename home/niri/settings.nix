{
  config,
  pkgs,
  ...
}:
{
  # 工作区完全动态，不预定义任何工作区
  #（rules.nix 中引用的 code/terminal/media 等工作区按需自动创建）

  # 禁用客户端装饰
  prefer-no-csd = true;

  # 快捷键提示层设置
  hotkey-overlay = {
    skip-at-startup = true;
  };

  # 布局与外观
  layout = {
    background-color = "#00000000"; # 透明背景

    # 焦点环设置
    focus-ring = {
      enable = true;
      width = 1; # 从 KDL 移植：1
      active = {
        color = "#ABC7FF";
      }; # catppuccin-mocha Sapphire
      inactive = {
        color = "#585b70";
      }; # catppuccin-mocha Surface2
    };

    # 预设列宽
    preset-column-widths = [
      { proportion = 0.25; }
      { proportion = 0.5; }
      { proportion = 0.75; }
      { proportion = 1.0; }
    ];

    default-column-width = {
      proportion = 0.75;
    };

    gaps = 4;

    # 屏幕边缘内边距
    struts = {
      left = 8; # 从 KDL 移植：8（原为 2，但 8 可避免触发边缘滑动）
      right = 8;
      top = 1;
      bottom = 1;
    };

    # 如果你需要聚焦列居中，可以取消注释
    # center-focused-column = "on-overflow";
    # center-focused-column = "always";
  };

  # 输入设备设置
  input = {
    keyboard = {
      xkb = {
        layout = "us";
      };
      numlock = true; # 从 KDL 移植
    };

    touchpad = {
      click-method = "button-areas";
      dwt = true;
      dwtp = true;
      natural-scroll = true;
      scroll-method = "two-finger";
      tap = true;
      tap-button-map = "left-right-middle";
      middle-emulation = true;
      accel-profile = "adaptive";
      # 如果你需要更快的加速度，可以调整
      # accel-speed = 0.4;
    };

    focus-follows-mouse = {
      enable = true;
    };
    warp-mouse-to-focus = {
      enable = false;
    };
    workspace-auto-back-and-forth = true;

    # 禁用电源键处理（如果你需要）
    # disable-power-key-handling = true;
  };

  # 显示器输出设置
  outputs = {
    "eDP-1" = {
      mode = {
        width = 1920;
        height = 1080;
        refresh = 165.004;
      };
      scale = 1.0;
      position = {
        x = 0;
        y = 0;
      };
    };
    # 如果你有第二个显示器，可以像这样添加：
    # "DP-2" = {
    #   mode = {
    #     width = 2560;
    #     height = 1600;
    #     refresh = 60.001;
    #   };
    #   scale = 1.25;
    #   position = { x = -64; y = -1280; };
    # };
  };

  cursor = {
    size = 24;
    #theme = "WhiteSur-cursors";
    hide-when-typing = true;
    hide-after-inactive-ms = 1000; # ← 移到这里
  };

  # 环境变量
  environment = {
    # Wayland 后端设置
    CLUTTER_BACKEND = "wayland";
    GDK_BACKEND = "wayland,x11";
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";

    # 会话类型和桌面环境标识
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "niri";

    # 输入法环境变量（fcitx）
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    GLFW_IM_MODULE = "fcitx";

    # Qt 主题设置（从 KDL 移植）
    QT_QPA_PLATFORMTHEME = "gtk3";
    QT_QPA_PLATFORMTHEME_QT6 = "gtk3";

    XCURSOR_THEME = "macOS-White";
    XCURSOR_SIZE = "24";

    # GTK 主题（可选）
    # GTK_THEME = "WhiteSur-Dark";
    # GTK_ICON_THEME = "WhiteSur";
    # GTK_FONT_NAME = "Sans 10";

    # 多 GPU 输出顺序（如果你的系统有多个 GPU）
    # WLR_DRM_DEVICES = "/dev/dri/by-path/pci-0000:06:00.0-card:/dev/dri/by-path/pci-0000:01:00.0-card";
  };
}
