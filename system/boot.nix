{pkgs, ...}: {
  boot = {
    loader = {
      systemd-boot = {
        enable = true;

        configurationLimit = 5;
      };

      efi = {
        efiSysMountPoint = "/boot/efi";

        canTouchEfiVariables = false;
      };
    };

    # 注：/tmp 已是 tmpfs（hardware-configuration.nix），无需 cleanOnBoot

    kernelPackages = pkgs.linuxPackages_latest;

    kernelParams = [
      "amd_pstate=passive"

      "nowatchdog"
    ];
  };
}
