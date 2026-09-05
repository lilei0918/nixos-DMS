{
  pkgs,
  inputs,
  ...
}: {
  boot = {
    loader = {
      # Dual boot: Windows lives on a separate ESP (nvme0n1p1),
      # GRUB is installed on the NixOS ESP (/boot/efi = nvme0n1p6).
      timeout = 5;

      grub = {
        enable = true;

        efiSupport = true;

        device = "nodev";

        # GRUB theme: nixos-grub-themes 'nixos' (NixOS default look)
        theme = inputs.nixos-grub-themes.packages.${pkgs.system}.nixos;

        # Deterministically add Windows: locate the separate Windows ESP (p1)
        # by filesystem UUID instead of scanning all disks for bootmgfw.efi,
        # which is flaky at boot. No os-prober dependency.
        extraEntries = ''
          menuentry "Windows 11" {
            insmod part_gpt
            insmod fat
            search --fs-uuid --set=root 785A-7651
            chainloader /EFI/Microsoft/Boot/bootmgfw.efi
          }
        '';

        # Keep NixOS first and the default entry.
        extraEntriesBeforeNixOS = false;
      };

      efi = {
        efiSysMountPoint = "/boot/efi";

        canTouchEfiVariables = true;
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
