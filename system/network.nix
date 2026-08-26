{
  networking = {
    hostName = "nixos";

    networkmanager = {
      enable = true;

      wifi.backend = "wpa_supplicant";

      wifi.powersave = false;
    };

    # timesyncd.enable 默认即为 true，只需覆盖 NTP 服务器
    timeServers = [
      "ntp.aliyun.com"

      "ntp.tencent.com"
    ];
  };
}
