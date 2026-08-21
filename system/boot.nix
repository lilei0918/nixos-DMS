{pkgs, ...}: {
  boot = {
    loader = {
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

    tmp.cleanOnBoot = true;

    kernelPackages = pkgs.linuxPackages_latest;

    kernelParams = [
      "amd_pstate=passive"

      "nowatchdog"
    ];
  };
}
