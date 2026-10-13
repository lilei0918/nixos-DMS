_: {
  ################################
  # 媒体库存储：nvme0n1 上的独立 btrfs 分区挂到 /srv/immich
  ################################
  # 仅“托管库”（手机上传/Immich 自己管理的文件）需要放在 Linux 文件系统（btrfs/ext4），
  # 不能用 NTFS（属主/权限/大小写不兼容）。NTFS 上的既有照片可作“外部库”原地只读索引，无需搬移。
  # 不建此分区也行：可先用默认 /var/lib/immich（根 btrfs，150G），容量不够再补。
  #
  # 用 cfdisk 建分区（交互式，只动 p1..p6 之后的空闲空间，不碰 Windows 分区）：
  #   sudo cfdisk /dev/disk/by-id/nvme-SKHynix_HFS512GDE9X084N_CJA5N775913905S66
  #     · 上下键选中末尾那块约 325G 的 “Free space”
  #     · 左右键到 [New] 回车；Size 直接回车（用全部剩余空间）
  #     · Type 保持 “Linux filesystem” 即可
  #     · [Write] 回车 → 输入 yes 回车 → [Quit] 退出
  #   sudo partx -u /dev/nvme0n1                 # 让内核重读分区表（也可省略，cfdisk 一般已做）
  #   sudo mkfs.btrfs -L IMMICH /dev/nvme0n1p7   # 新建分区通常是 p7
  # 挂载用文件系统标签（by-label），无需给 GPT 分区命名，故不必用 sfdisk/gdisk。
  # 回退：sudo sfdisk --delete /dev/nvme0n1 7

  fileSystems."/srv/immich" = {
    device = "/dev/disk/by-label/IMMICH";
    fsType = "btrfs";
    options = ["compress=zstd" "noatime" "discard=async"];
  };

  ################################
  # Immich 服务（nixpkgs 原生模块：自带 PostgreSQL + Redis + ML）
  ################################
  # 托管库 mediaLocation(= /srv/immich)；数据库/缓存/缩略图元数据在 /var/lib/immich（根 btrfs）。
  # 当前启用局域网访问：监听所有接口 + 放行 2283（远程访问以后再经 Tailscale 追加）。

  services.immich = {
    enable = true;

    # 空串 = 监听所有接口（局域网手机可访问）
    host = "";

    port = 2283;

    # 放行 TCP 2283（供局域网访问）
    openFirewall = true;

    mediaLocation = "/srv/immich";

    # AMD Radeon Vega 核显硬件转码
    accelerationDevices = ["/dev/dri/renderD128"];
  };
}
