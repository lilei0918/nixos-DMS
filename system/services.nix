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
      ppdSettings.main.default = "balanced"; # balanced / performance / power-saver
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

  security = {
    rtkit.enable = true;

    # GNOME Keyring
    pam.services.greetd.enableGnomeKeyring = true;
  };
}
