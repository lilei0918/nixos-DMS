{
  networking = {
    hostName = "nixos";

    networkmanager.enable = true;

    wireless = {
      userControlled = false;
    };

    networkmanager = {
      wifi.backend = "wpa_supplicant";

      wifi.powersave = false;
    };

    firewall = {
      trustedInterfaces = [
        "Meta"
      ];

      checkReversePath = "loose";
    };
  };

  services.timesyncd.enable = true;

  networking.timeServers = [
    "ntp.aliyun.com"

    "ntp.tencent.com"
  ];
}
