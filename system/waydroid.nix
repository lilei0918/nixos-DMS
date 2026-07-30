{
  config,
  pkgs,
  ...
}: {
  # 启用 Waydroid 所需的容器支持
  virtualisation.lxc.enable = true;
  virtualisation.lxd.enable = true;

  # 启用 Waydroid
  virtualisation.waydroid.enable = true;

  # 启用 Binder 和 Ashmem（Waydroid 内核模块）
  boot.kernelModules = ["binder_linux" "ashmem_linux"];

  # 启用 Waydroid systemd 服务
  systemd.services.waydroid-container.enable = true;

  # 安装必要的软件包
  environment.systemPackages = with pkgs; [
    waydroid
    android-tools
    lxc
    dnsmasq
    iproute2
    iptables
    nss
    wget
  ];

  # NAT 配置：使用 Wi-Fi 接口（wlp4s0）
  networking.firewall.enable = true;
  networking.nat = {
    enable = true;
    externalInterface = "wlp4s0";
    internalInterfaces = ["waydroid0"];
  };

  # Waydroid 容器 DNS
  networking.extraHosts = ''
    127.0.0.1 waydroid.lan
  '';

  # PipeWire + PulseAudio 声音支持
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # 启用 DBus 和 XDG portal
  services.dbus.enable = true;
  xdg.portal.enable = true;

  # 启用 cgroup 支持
  boot.kernelParams = ["cgroup_enable=memory" "swapaccount=1"];

  # Waydroid 自启动
  systemd.services."waydroid-container" = {
    wantedBy = ["multi-user.target"];
  };

  # 创建网络桥 waydroid0
  networking.bridges.waydroid0.interfaces = [];
}
