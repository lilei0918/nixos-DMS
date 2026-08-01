{pkgs, ...}: {
  boot.loader = {
    grub.enable = false;

    systemd-boot = {
      enable = true;

      configurationLimit = 5;
    };

    efi = {
      efiSysMountPoint = "/boot/efi";

      canTouchEfiVariables = false;
    };
  };

  boot.tmp.cleanOnBoot = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.kernelParams = [
    "amd_pstate=passive"

    "nowatchdog"
  ];
}
