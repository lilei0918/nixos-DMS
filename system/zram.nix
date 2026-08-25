# ZRAM 内存压缩交换
# 来源参照: ryan4yin/nix-config modules/nixos/base/zram.nix
# 作用: 在内存中开辟 zstd 压缩交换区(约内存一半), 不活跃页压缩存放,
#       压缩比通常 ~3:1, 零磁盘 IO、SSD 零磨损, 同时补上无 swap 时的 OOM 防护缺口
{lib, ...}: {
  # 启用内核 zram 模块提供的内存压缩交换设备
  zramSwap = {
    enable = true;
    # 压缩算法: zstd (压缩比与速度的平衡最佳)
    algorithm = lib.mkDefault "zstd";
    # 优先级高于磁盘 swap (当前系统无磁盘 swap, 此值仅作预留)
    priority = lib.mkDefault 100;
    # zram 可存储的最大数据量 = 物理内存的 50% (32G 内存 → 16G zram 容量)
    memoryPercent = lib.mkDefault 50;
  };

  # 针对 zram 的内核参数调优
  boot.kernel.sysctl = {
    # swappiness: 越高越积极使用 swap; zram 等内存型 swap 建议 >100
    "vm.swappiness" = lib.mkDefault 180;

    # 关闭 watermark boost, 避免过早回收内存页
    "vm.watermark_boost_factor" = lib.mkDefault 0;

    # 提前触发后台回收 (12.5% 水位), 防止高 swappiness 下突发 swap 风暴
    "vm.watermark_scale_factor" = lib.mkDefault 125;

    # page-cluster=0: 禁用 swap 预读 (zram 低延迟, 预读反而浪费)
    "vm.page-cluster" = lib.mkDefault 0;
  };
}
