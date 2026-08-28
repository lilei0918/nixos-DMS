{pkgs, ...}: {
  # Enable OpenGL / Vulkan
  hardware.graphics.enable = true;

  boot = {
    kernelModules = ["nvidia_modeset" "nvidia_drm" "nvidia"];

    blacklistedKernelModules = ["nouveau"];

    # niri(Wayland) 下若 NVIDIA 作为主显示需 framebuffer 兼容; offload 模式(核显输出)可不开
    # kernelParams = [ "nvidia_drm.fbdev=1" ];
  };

  # Load nvidia driver for Xorg and Wayland (XWayland 也走此驱动)
  services.xserver = {
    enable = true;
    videoDrivers = ["nvidia"];
  };

  hardware.nvidia = {
    # Modesetting is required (nvidia_drm modeset=1)。
    modesetting.enable = true;

    # 动态电源管理: 挂起/唤醒时保存 VRAM, 避免唤醒后花屏/崩溃。
    powerManagement.enable = true;

    # RTD3 细粒度电源管理: 独显空闲时进入 D3cold 完全断电。
    # 仅 PRIME offload 模式下生效(模块断言 finegrained -> offload.enable)。
    powerManagement.finegrained = true;

    # 开源内核模块: RTX 3060 (Ampere) 在官方支持列表, 595 驱动已稳定。
    # 若遇稳定性问题可改回 false(闭源模块)。
    open = true;

    nvidiaSettings = true;

    package = pkgs.linuxPackages_latest.nvidiaPackages.stable;

    prime = {
      # 按需渲染 (offload): 独显仅在应用显式请求时点亮, 闲置自动断电, 最省电。
      offload = {
        enable = true;
        # 生成 nvidia-offload 命令: 游戏/应用用 `nvidia-offload <cmd>` 强制走独显
        enableOffloadCmd = true;
      };
      # 备选: 需要独显常开时改用 sync.enable = true 并去掉 offload。
      # sync.enable = true;

      # Make sure to use the correct Bus ID values for your system!
      amdgpuBusId = "PCI:6:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
}
