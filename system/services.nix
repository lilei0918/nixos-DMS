{
  config,
  pkgs,
  ...
}: {
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
  # DBus
  ############################################

  services.dbus.enable = true;

  services.dbus.packages = with pkgs; [
    bluez
  ];

  ############################################
  # Power
  ############################################

  services.power-profiles-daemon.enable = true;

  ############################################
  # File manager / thumbnail
  ############################################

  services.gvfs.enable = true;

  services.tumbler.enable = true;

  ############################################
  # Audio Pipewire
  ############################################

  services.pipewire = {
    enable = true;

    alsa.enable = true;

    alsa.support32Bit = true;

    pulse.enable = true;

    jack.enable = true;

    wireplumber.enable = true;
  };

  security.rtkit.enable = true;

  ############################################
  # GNOME Keyring
  ############################################

  security.pam.services.greetd.enableGnomeKeyring = true;

  services.gnome.gnome-keyring.enable = true;

  ############################################
  # Hermes Agent
  ############################################
  services.hermes-agent = {
    enable = true;

    settings = {
      model.default = "deepseek-v4-flash"; # 改为你的模型
      toolsets = ["all"];
      terminal = {
        backend = "local";
        timeout = 180;
      };
    };

    environmentFiles = [
      config.sops.templates."hermes-env".path
    ];

    addToSystemPackages = true;
  };

  # 修复：auth.json 若属主是交互用户（lilei）则服务（hermes 用户）无法读取。
  # tmpfiles 规则在启动时把属主统一为 hermes:hermes（权限保持 600 属主可读写）。
  systemd.tmpfiles.rules = [
    "f /var/lib/hermes/.hermes/auth.json 0600 hermes hermes - -"
  ];

  # 修复：网关排空（drain）需要更长停止超时。
  # 上游模块未设置 TimeoutStopSec，systemd 默认 10s 会在网关排空时 SIGKILL。
  systemd.services.hermes-agent.serviceConfig.TimeoutStopSec = 30;

  ############################################
  # Hermes secrets
  ############################################

  sops.templates."hermes-env" = {
    content = ''

      DEEPSEEK_API_KEY=${config.sops.placeholder."deepseek_api_key"}

    '';
  };

  ############################################
  # Power / Bluetooth
  ############################################

  services.upower.enable = true;

  services.pulseaudio.enable = false;

  services.blueman.enable = true;
}
