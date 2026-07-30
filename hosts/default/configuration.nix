{
  config,
  pkgs,
  inputs,
  lib,
  self,
  ...
}:
{
  # ─────────────────────────────────────────────────────
  # 🔰 必要模块导入（必须放开头）
  # ─────────────────────────────────────────────────────
  imports = [
    ./hardware-configuration.nix
    "${self}/system/greeter/greetd.nix"
    #"${self}/system/programs/steam.nix"
    "${self}/system/programs/nvidia-block.nix"
    #"${self}/system/programs/glance.nix"
    "${self}/system/xdg.nix"
    #"${self}/system/waydroid.nix"
    "${self}/system/fonts.nix"
    "${self}/system/input.nix"
    "${self}/system/mihomo.nix"
    #"${self}/system/environment.nix"
    "${self}/system/packages.nix"

    #"${self}/system/filesystems.nix" #polkit-gnome
    inputs.home-manager.nixosModules.default
  ];

  ########################################
  # 核心：AMDGPU + 硬件解码 + Wayland
  ########################################
  hardware.graphics = {
    enable = true; # 取代旧的 hardware.opengl
    # Vega iGPU 用 Mesa/RADV，别装 amdvlk
    extraPackages = with pkgs; [
      mesa # OpenGL/VA-API/Vulkan 驱动（radeonsi/radv）
      libva # VA-API 基础库
      # vaapiVdpau # VA-API→VDPAU 兼容层（一些应用会用到）
      libvdpau # VDPAU
      vulkan-loader
      vulkan-tools # vulkaninfo
      vulkan-validation-layers
      ffmpeg # 含 vaapi 支持的 ffmpeg
    ];
  };

  # 启用 DMS 系统服务
  programs.dms-shell = {
    enable = true;

    # 开启 systemd 服务，实现开机自启和自动重启
    systemd = {
      enable = true;
      restartIfChanged = true;
    };

    # 按需开启你需要的功能
    enableSystemMonitoring = true;
    enableDynamicTheming = true;
    enableAudioWavelength = true;
    enableVPN = true;
    enableCalendarEvents = true;
  };

  # ─────────────────────────────────────────────────────
  # 1️⃣ Nix 基础设置：源、功能、GC
  # ─────────────────────────────────────────────────────
  nixpkgs.overlays = [
    (final: prev: {
      nur = import inputs.nur {
        nurpkgs = prev;
        pkgs = prev;
      };
    })
  ];

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    auto-optimise-store = true;

    substituters = [
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store?priority=1"
      "https://mirrors.ustc.edu.cn/nix-channels/store?priority=2"
      "https://cache.nixos.org?priority=20"
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 5d";
  };

  nixpkgs.config.allowUnfree = true;

  # ─────────────────────────────────────────────────────
  # 2️⃣ 系统启动与文件系统
  # ─────────────────────────────────────────────────────
  boot.loader = {
    # 方案A：Arch GRUB 主导，NixOS 用 systemd-boot 落到共享 ESP（p6 = 9B06-514F）
    # 不抢 NVRAM 启动项，由 Arch GRUB 的 /etc/grub.d/40_custom chainload 跳转
    grub.enable = false;
    systemd-boot = {
      enable = true;
      configurationLimit = 5;
    };
    efi.efiSysMountPoint = "/boot/efi"; # 与 Arch 一致（原 /boot）
    efi.canTouchEfiVariables = false; # 不注册 NVRAM 启动项（原 true）
  };
  boot.tmp.cleanOnBoot = true; # 每次启动清空 /tmp
  # ─────────────────────────────────────────────────────
  # 3️⃣ 用户与 Home Manager
  # ─────────────────────────────────────────────────────
  users.users.lilei = {
    isNormalUser = true;
    description = "lilei";
    homeMode = "711";
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "input"
      "hermes"
    ];
    hashedPassword = "***REMOVED***";
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users = {
      "lilei" = import ./home.nix;
    };
    backupFileExtension = "backup";
  };

  programs.dconf.enable = true;

  # ─────────────────────────────────────────────────────
  # 4️⃣ 本地化
  # ─────────────────────────────────────────────────────
  time.timeZone = "Asia/Shanghai"; # 北京
  #减少启动时多次重复尝试同步时间
  services.timesyncd.enable = true;
  networking.timeServers = [
    "ntp.aliyun.com"
    "ntp.tencent.com"
  ];

  console.keyMap = "us";
  # ─────────────────────────────────────────────────────
  # 5️⃣ 图形界面与服务（X、音频、GVFS 等）
  # ─────────────────────────────────────────────────────
  #boot.kernelModules = [ ];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.kernelParams = [
    #"quiet"
    #"loglevel=3"
    #"nvidia-drm.modeset=1"     # 启用 DRM/KMS 支持，Wayland 需要
    #"module_blacklist=nouveau" # 禁用 nouveau，避免驱动冲突
    "amd_pstate=passive" # 5800H 建议被动模式，稳定省心
    "nowatchdog"
  ]; # 启动时附加参数
  #boot.extraModulePackages = [ ];

  services = {
    xserver = {
      enable = true;
      videoDrivers = [ "amdgpu" ];
      xkb = {
        layout = "us";
        variant = "";
      };
    };

    dbus.enable = true;
    dbus.packages = with pkgs; [ bluez ];

    power-profiles-daemon.enable = true; # 用 power-profiles-daemon 管理电源档位（Balanced/Power Saver/Performance）
    # printing.enable = true;
    gvfs.enable = true;
    tumbler.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      # ✅ 蓝牙音频支持
      wireplumber.enable = true;
    };
  };

  security.rtkit.enable = true;

  programs.zsh.enable = true;

  services.hermes-agent = {
    enable = true;
    settings.model.default = "tencent/hy3:free";
    #environmentFiles = [ config.sops.secrets."hermes-env".path ];
    addToSystemPackages = true;
  };

  services.upower.enable = true; # QuickShell 等组件访问 UPower 接口获取电池状态

  # ─────────────────────────────────────────────────────
  # 6️⃣ 硬件支持（蓝牙、固件、udev）
  # ─────────────────────────────────────────────────────
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.enableRedistributableFirmware = true;
  services.pulseaudio.enable = false;

  services.udev.packages = [ pkgs.rwedid ];
  services.fstrim.enable = true;
  services.btrfs.autoScrub.enable = true;

  services.blueman.enable = true;

  services.gnome.gnome-keyring.enable = true;

  #services.gnome-keyring.enable = true;

  #security.pam.services.login.enableGnomeKeyring = true;
  #security.pam.services.sddm.enableGnomeKeyring = true; # if you are using a display manager you might also need to do this
  security.pam.services.greetd.enableGnomeKeyring = true;

  #蓝牙软解锁
  #services.udev.extraRules = ''
  #SUBSYSTEM=="bluetooth", ACTION=="add", RUN+="${pkgs.rfkill}/bin/rfkill unblock bluetooth"
  #'';

  # ─────────────────────────────────────────────────────
  # 7️⃣ 网络配置
  # ─────────────────────────────────────────────────────
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    wireless = {
      #  enable = false;
      userControlled = false;
    };
    networkmanager = {
      wifi.backend = "wpa_supplicant";
      wifi.powersave = false;
    };

    firewall = {
      trustedInterfaces = [ "Meta" ]; # 与 TUN 设备名一致
      checkReversePath = "loose";
    };
  };

  # ─────────────────────────────────────────────────────
  # 9️⃣ 系统状态版本 & 激活脚本
  # ─────────────────────────────────────────────────────
  system.stateVersion = "25.05";

  system.activationScripts.logRebuildTime = {
    text = ''
      LOG_FILE="/var/log/nixos-rebuild-log.json"
      TIMESTAMP=$(date "+%d/%m")
      GENERATION=$(readlink /nix/var/nix/profiles/system | grep -o '[0-9]\+')
      echo "{\"last_rebuild\": \"$TIMESTAMP\", \"generation\": $GENERATION}" > "$LOG_FILE"
      chmod 644 "$LOG_FILE"
    '';
  };
}
