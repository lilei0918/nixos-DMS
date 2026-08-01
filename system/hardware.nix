{
  pkgs,
  ...
}:

{

  hardware.graphics = {

    enable = true;

    extraPackages = with pkgs; [

      libva

      libvdpau

      vulkan-loader

      vulkan-tools

      vulkan-validation-layers

    ];

  };

  hardware.bluetooth = {

    enable = true;

    powerOnBoot = true;

  };

  hardware.enableRedistributableFirmware = true;

  services.udev.packages = [

    pkgs.rwedid

  ];

  services.fstrim.enable = true;

  services.btrfs.autoScrub = {

    enable = true;

  };

}
