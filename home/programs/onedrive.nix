{
  config,
  pkgs,
  ...
}: let
  # ← 按需修改本地与云端路径
  syncSrc = "${config.home.homeDirectory}/onedrive_push";
  syncDst = "onedrive:nixosPush";
in {
  # 切换后自动重启用户服务（推荐）
  systemd.user.startServices = "sd-switch";

  home.packages = [pkgs.rclone pkgs.bash];

  # 确保本地目录存在
  home.file."onedrive_push/.keep".text = "";

  # 可选忽略清单（目录级 copy 时使用；不需要可删 --exclude-from）
  home.file.".config/rclone/ignore.txt".text = ''
    ~$*.xls*
    .~lock.*#
    *.tmp
    *.part
    *.swp
    .DS_Store
    Thumbs.db
    .git/**
  '';

  # ② 手动脚本：随时同步整个目录（本地→云端，不删除远端）
  home.file.".local/bin/onedrive-sync-all".text = ''
    #!${pkgs.bash}/bin/bash
    set -euo pipefail
    SRC="${syncSrc}"
    DST="${syncDst}"
    exec ${pkgs.rclone}/bin/rclone copy "$SRC" "$DST" \
      --update --fast-list --create-empty-src-dirs \
      --exclude-from "$HOME/.config/rclone/ignore.txt" \
      --transfers 8 --checkers 16 --progress "$@"
  '';
  home.file.".local/bin/onedrive-sync-all".executable = true;

  # ① 开机/登录后自动同步一次（oneshot）
  systemd.user.services."onedrive-sync-on-boot" = {
    Unit = {Description = "OneDrive sync once at boot/login (local -> cloud)";};
    Service = {
      Type = "oneshot";
      ExecStart = ''
        ${pkgs.rclone}/bin/rclone copy ${syncSrc} ${syncDst} \
          --update --fast-list --create-empty-src-dirs \
          --exclude-from %h/.config/rclone/ignore.txt \
          --transfers 8 --checkers 16 \
          --log-file=%h/.local/share/onedrive-sync.log --log-level=INFO
      '';
    };
  };
  systemd.user.timers."onedrive-sync-on-boot" = {
    Unit = {Description = "Run OneDrive sync once after boot/login";};
    Timer = {
      OnBootSec = "30s";
      Persistent = true;
    };
    Install = {WantedBy = ["timers.target"];};
  };

  # 让 ~/.local/bin 进 PATH（便于直接调用脚本）
  home.sessionPath = ["${config.home.homeDirectory}/.local/bin"];
}
