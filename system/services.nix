{pkgs, ...}: {
  ############################################
  # DankMaterialShell
  ############################################

  programs.dms-shell = {
    enable = true;

    systemd = {
      enable = true;

      restartIfChanged = true;
    };

    enableSystemMonitoring = true;

    enableDynamicTheming = true;

    enableAudioWavelength = true;

    enableVPN = true;

    enableCalendarEvents = true;
  };

  ############################################
  # Services
  ############################################

  services = {
    dbus = {
      enable = true;

      packages = with pkgs; [
        bluez
      ];
    };

    # 电源调度: tuned (参照 ryan4yin/nix-config desktop/power.nix)
    # 替代 power-profiles-daemon —— 全系统功耗策略, ppdSupport 提供兼容 API
    # (DMS 桌面壳的电源档位切换不受影响)
    tuned = {
      enable = true;
      settings.dynamic_tuning = true;
      ppdSupport = true;
      ppdSettings.main.default = "power-saver"; # balanced / performance / power-saver
    };
    power-profiles-daemon.enable = false; # 与 tuned 冲突, 必须关闭

    gvfs.enable = true;

    tumbler.enable = true;

    # Audio Pipewire
    pipewire = {
      enable = true;

      alsa.enable = true;

      alsa.support32Bit = true;

      pulse.enable = true;

      jack.enable = true;

      wireplumber.enable = true;
    };

    gnome."gnome-keyring".enable = true;

    # Hermes Agent（hermes-agent 服务）已移至 home/programs/AI/hermes-service.nix
    upower.enable = true;

    pulseaudio.enable = false;

    blueman.enable = true;
  };

  ############################################
  # Legion 默认静音模式 (platform_profile = low-power)
  # 独显已在 BIOS 屏蔽, 但 EC 若停在性能模式, 双风扇高转 + 电源键红灯;
  # 开机与每次唤醒后强制写回 low-power(静音)。Fn+Q / DMS 手动切换仍可覆盖。
  ############################################

  systemd.services."quiet-fan-boot" = {
    description = "Force quiet platform profile at boot";
    after = ["tuned.service" "multi-user.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig.Type = "oneshot";
    script = ''
      if [ -w /sys/firmware/acpi/platform_profile ]; then
        echo low-power > /sys/firmware/acpi/platform_profile
      fi
    '';
  };

  systemd.services."quiet-fan-resume" = {
    description = "Reapply quiet platform profile after resume";
    after = ["suspend.target" "hibernate.target" "hybrid-sleep.target"];
    wantedBy = ["suspend.target" "hibernate.target" "hybrid-sleep.target"];
    serviceConfig.Type = "oneshot";
    script = ''
      if [ -w /sys/firmware/acpi/platform_profile ]; then
        echo low-power > /sys/firmware/acpi/platform_profile
      fi
    '';
  };

  security = {
    rtkit.enable = true;

    # GNOME Keyring
    pam.services.greetd.enableGnomeKeyring = true;
  };
}
