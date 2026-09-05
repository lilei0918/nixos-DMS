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

        # GRUB theme: nixos-grub-themes 'bigsur' (macOS look)
        theme = inputs.nixos-grub-themes.packages.${pkgs.system}.big-sur;

        # Deterministically add Windows: GRUB scans all disks at boot for
        # bootmgfw.efi (across the separate ESP), no os-prober dependency.
        extraEntries = ''
          menuentry "Windows 11" {
            search --file /EFI/Microsoft/Boot/bootmgfw.efi --set=root
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
