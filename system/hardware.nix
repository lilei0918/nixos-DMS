{pkgs, ...}: {
  hardware = {
    graphics = {
      enable = true;

      extraPackages = with pkgs; [
        libva

        libvdpau

        vulkan-loader

        vulkan-tools

        vulkan-validation-layers
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
