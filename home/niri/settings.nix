_: {
  # 命名工作区（供 rules.nix 的 open-on-workspace 使用）
  # ⚠️ niri 的 open-on-workspace 不会自动创建工作区，必须在此声明，否则窗口落到当前工作区
  # ⚠️ 工作区按 key 排序创建，因此用数字前缀控制顺序，再用 name 指定实际名称
  workspaces = {
    "1-browser" = {
      name = "browser";
    };
    "2-note" = {
      name = "note";
    };
    "3-code" = {
      name = "code";
    };
  };

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
      {proportion = 0.25;}
      {proportion = 0.5;}
      {proportion = 0.75;}
      {proportion = 1.0;}
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
    "eDP-2" = {
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
    "DP-2" = {
      mode = {
        width = 2560;
        height = 1600;
        refresh = 60.001;
      };
      # 16 英寸 2.5K（约 189 PPI）相对内屏 1080p（约 141 PPI）做 1.25 缩放，
      # 使字号接近内屏；逻辑分辨率 2048x1280
      scale = 1.25;
      # 外接屏物理位于笔记本屏幕正上方：y 取负使其处于 eDP-2 上方，
      # x 用 (1920 - 2048) / 2 = -64 水平居中
      position = {
        x = -64;
        y = -1280;
      };
    };
  };

  cursor = {
    size = 24;
    #theme = "WhiteSur-cursors";
    hide-when-typing = true;
    hide-after-inactive-ms = 1000;
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

    # ⚠️ 输入法变量（GTK/QT_IM_MODULE、XMODIFIERS、QT_IM_MODULES）
    #    统一在 home/programs/rime.nix 管理，勿在此重复声明
    # ⚠️ Qt 主题 / XCURSOR 变量统一在 home/programs/theme.nix 管理，勿在此重复声明

    # GTK 主题（可选）
    # GTK_THEME = "WhiteSur-Dark";
    # GTK_ICON_THEME = "WhiteSur";
    # GTK_FONT_NAME = "Sans 10";

    # 多 GPU 输出顺序（如果你的系统有多个 GPU）
    # WLR_DRM_DEVICES = "/dev/dri/by-path/pci-0000:06:00.0-card:/dev/dri/by-path/pci-0000:01:00.0-card";
  };
}
