{
  config,
  myvars,
  ...
}: {
  ############################################
  # 易失文件系统（volatile）
  #
  # /tmp        ：系统临时文件，4G 上限
  # ~/.cache    ：所有用户级缓存均为易失数据，6G 上限，重启即空
  #
  # tmpfs 的 size 是上限、按实际占用计内存，并非开机立即吃满。
  # 代价：每次开机 fontconfig / mesa shader / uv / pip / ~/.cache/nix
  #       （eval 缓存）等按需重建，相关程序首次启动略慢。
  ############################################

  fileSystems."/tmp" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = ["mode=1777" "nosuid" "nodev" "size=4G"];
  };

  fileSystems."${myvars.homeDirectory}/.cache" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [
      "mode=0700"
      "uid=${toString config.users.users.${myvars.username}.uid}"
      "gid=${toString config.users.groups.${config.users.users.${myvars.username}.group}.gid}"
      "nosuid"
      "nodev"
      "size=6G"
    ];
  };
}
