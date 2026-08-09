{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix

    ################################
    # system modules
    ################################

    ../../system/nix.nix

    ../../system/boot.nix

    ../../system/hardware.nix

    ../../system/network.nix

    ../../system/services.nix

    ################################
    # desktop
    ################################

    ../../system/fonts.nix

    ../../system/input.nix

    ../../system/xdg.nix

    ################################
    # programs
    ################################

    ../../system/nvidia/nvidia-block.nix

    ################################
    # proxy (daed 主用，mihomo 备用)
    ################################

    ../../system/proxy/daed.nix

    # 备用：切回 mihomo 时注释上面这行，取消下面这行注释
    # ../../system/proxy/mihomo.nix

    ../../system/packages.nix

    ../../system/vault/vaultwarden.nix

    ../../system/vault/vaultwarden-backup.nix

    ../../system/vault/vault.nix

    ################################
    # greeter
    ################################

    ../../system/greetd.nix

    ################################
    # secrets
    ################################

    ../../system/secrets.nix
  ];

  ################################
  # User
  ################################

  users.users.lilei = {
    isNormalUser = true;

    description = "lilei";

    shell = pkgs.zsh;

    extraGroups = [
      "wheel"

      "networkmanager"

      "video"

      "input"

      "hermes"
    ];

    # 密码 hash 不提交明文仓库：sops 加密存在 secrets/secrets.yaml
    # 修改：sops secrets/secrets.yaml 更新 password_hash 值，再 nixos-rebuild switch
    hashedPasswordFile = config.sops.secrets.password_hash.path;
  };

  ################################
  # Home Manager
  ################################

  home-manager = {
    useGlobalPkgs = true;

    useUserPackages = true;

    # 给 home.nix / hermes.nix 使用 flake inputs

    extraSpecialArgs = {
      inherit inputs;
    };

    users.lilei = import ./home.nix;

    backupFileExtension = "backup";
  };

  ################################
  # dconf
  ################################

  programs.dconf.enable = true;

  ################################
  # DATATB 数据盘自动挂载 (NTFS, ntfs3)
  # 挂载点与 udisks2 自动挂载路径保持一致，daA 的 TDX_DATA_DIR 无需改动
  ################################

  fileSystems."/run/media/lilei/DATATB" = {
    device = "/dev/disk/by-label/DATATB";
    fsType = "ntfs3";
    options = [
      "uid=1000"
      "gid=100"
      "umask=022"
      "nofail"
      "x-systemd.automount"
    ];
  };

  ################################
  # Locale
  ################################

  time.timeZone = "Asia/Shanghai";

  console.keyMap = "us";

  ################################
  # Shell
  ################################

  programs.zsh.enable = true;

  ################################
  # NixOS version
  ################################

  system.stateVersion = "25.05";

  ################################
  # rebuild log
  ################################

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
