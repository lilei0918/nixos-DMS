{pkgs, ...}: {
  hardware = {
    graphics = {
      enable = true;

      extraPackages = with pkgs; [
        libva

        libvdpau

        vulkan-loader

        vulkan-tools

        # 注：vulkan-validation-layers 仅 Vulkan 调试用，不进常驻图形栈
      ];
    };

    bluetooth = {
      enable = true;

      powerOnBoot = true;
    };

    enableRedistributableFirmware = true;
  };

  services = {
    udev.packages = [
      pkgs.rwedid
    ];

    fstrim.enable = true;

    btrfs.autoScrub.enable = true;
  };
}
