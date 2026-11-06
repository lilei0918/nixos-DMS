# disko 分区描述 —— ZHITAI TiPlus7100 1TB（NixOS 主盘）当前布局的「复现参考」
#
# ⚠️⚠️ 安全声明
#   1. 本文件【未被任何模块导入】（configuration.nix 里没有引用），不会随 `nh os switch` 生效；
#      它只是「换盘/重装时复刻这台机器的分区」的说明书，同时供人和 agent 阅读。
#   2. 本盘的现有分区表是 **MBR（dos）**，不是 GPT —— 这是 2026-11-07 实测结论。
#      因此这里必须用 disko 的 legacy `table` + `format = "msdos"`（上游已把该类型标为
#      deprecated，但它是目前唯一能如实描述 MBR 的写法）。
#   3. 在任何**已有数据**的盘上运行 disko 都可能造成不可逆的数据丢失：
#        - `--mode create` 会重建分区表（`parted mklabel`），DATATB / 根分区 / Vault 全部消失；
#        - `--mode format` 会格式化被声明了 content 的分区（本文件只有 NIXOS 根分区带 content）。
#      运行前请确认设备 by-id 指向的是**目标盘**，并且目标盘上没有要保留的数据。
#   4. 设备名 `nvme0n1` / `nvme1n1` 会随硬件枚举顺序变化（本机就发生过互换），
#      所以本文件只用 by-id；运行/排查时也请一律用 UUID / by-id / LUKS UUID。
#
# ── 2026-11-07 实测（只读命令：lsblk / ls -l /dev/disk/by-* / /sys/class/block/*/{start,size}）
#
#   盘：/dev/disk/by-id/nvme-ZHITAI_TiPlus7100_1TB_ZTA71T0AB24182L6AD
#       容量 2000409264 扇区 = 953.87 GiB，分区表 = dos(MBR)
#
#   编号  物理顺序  起点(扇区)      大小            文件系统/标签            稳定标识
#   ─────────────────────────────────────────────────────────────────────────────
#   p1    第 1      2048            1643888640 (783.8672 GiB)  NTFS "DATATB"   UUID FAC6848EC6844D37
#   p3    第 2      1643890688       41943040 (20.0000 GiB)   LUKS2           LUKS UUID 86c742fc-8de5-4c59-9a30-196484a35695
#   p2    第 3      1685833728      314575536 (150.0013 GiB)  btrfs "NIXOS"   UUID 6c9764ff-c293-4be8-801c-982bdb6ed30a
#
#   注意两点：
#     · 物理顺序是 DATATB → VAULT → NIXOS，但**编号**是 p1/p2/p3 = DATATB/NIXOS/VAULT
#       （p2 在盘尾、p3 在中间）。本文件的分区列表顺序保持 p1→p2→p3，以便
#       `--mode format,mount` 对准的分区与现有编号一致（否则会误格式化 Vault）。
#     · btrfs 子卷实测：`/`=@、`/home`=@home、`/nix`=@nix、`/var/log`=@log，
#       挂载选项 `noatime,compress=zstd:3,discard=async`。
#
# ── 本盘之外的引导/系统分区（**不在本文件管辖**，在另一块 SK Hynix 512G 上）
#
#   Windows ESP      by-uuid 785A-7651     （GRUB 菜单 `search --fs-uuid 785A-7651`）
#   NixOS ESP        by-uuid AC09-EF5B     （挂载 /boot/efi，GRUB 主引导写在这里）
#   Windows 11       by-uuid 68D4EDC8D4ED9918
#   Immich 媒体库     by-label IMMICH      （by-uuid 5c0e846a-5822-4059-bb93-f0256dd2a81c，挂载 /srv/immich）
#
# ── 用法
#
#   a) 在新盘上复刻本机布局（会清空目标盘）：
#        nix run github:nix-community/disko -- --mode create,format,mount ./hosts/legion/disko-fs.nix
#   b) 只重建 NixOS 根分区（假设分区表已存在且编号一致；会清空 p2）：
#        nix run github:nix-community/disko -- --mode format,mount ./hosts/legion/disko-fs.nix
#   c) 只检查将要执行的磁盘命令，不动磁盘：
#        nix run github:nix-community/disko -- --dry-run --mode create ./hosts/legion/disko-fs.nix
#
#   注意：MBR 只有 4 个主分区槽位，本盘已用 3 个；若将来要加分区，需先评估是否转 GPT
#   （转 GPT 会改变分区表类型，但可用 `sgdisk -g` 原地转换，需先备份）。
#   ⚠️ 永远不要用 `--mode destroy`。
{
  disko.devices.disk.zhitai = {
    type = "disk";
    device = "/dev/disk/by-id/nvme-ZHITAI_TiPlus7100_1TB_ZTA71T0AB24182L6AD";

    content = {
      # 实测为 MBR；disko 的 legacy table 用 format = "msdos" 描述
      type = "table";
      format = "msdos";

      # 顺序 = 分区编号（p1/p2/p3）。物理位置见每个分区的 start/end。
      # 注意：创建时 p2（盘尾）先于 p3（中间）分配。parted 允许指定任意不重叠的 start/end；
      # 若你的 parted 版本拒绝这种乱序创建，可改为按物理顺序（p1→VAULT→NIXOS）创建，
      # 编号随之变化——系统里所有挂载都用 UUID/标签，编号不影响可启动性。
      partitions = [
        {
          # p1：DATATB 数据盘（NTFS，挂载 /run/media/lilei/DATATB）
          name = "DATATB";
          part-type = "primary";
          # parted 的 fs-type 只用来设置 MBR 分区类型码（ntfs → 0x07），不会创建文件系统
          fs-type = "ntfs";
          start = "2048s"; # 1 MiB
          end = "1643890687s"; # 783.8672 GiB
          #
          # ⚠️ 现有盘上【不要】打开下面这段，否则会格式化 DATATB：
          # content = {
          #   type = "filesystem";
          #   format = "ntfs";
          #   extraArgs = [ "-f" "-L" "DATATB" ];
          #   mountpoint = "/run/media/lilei/DATATB";
          #   mountOptions = [ "uid=1000" "gid=100" "umask=022" "nofail" "x-systemd.automount" ];
          # };
        }

        {
          # p2：NixOS 根分区（btrfs + 子卷），盘尾，150 GiB
          name = "NIXOS";
          part-type = "primary";
          fs-type = "btrfs";
          start = "1685833728s"; # 803.8672 GiB
          end = "100%"; # 盘尾

          content = {
            type = "btrfs";
            extraArgs = ["-f"]; # 格式化（仅此分区；重装/复现时才用）

            subvolumes = {
              "@" = {
                mountpoint = "/";
                mountOptions = ["compress=zstd" "noatime" "discard=async"];
              };
              "@home" = {
                mountpoint = "/home";
                mountOptions = ["compress=zstd" "noatime" "discard=async"];
              };
              "@nix" = {
                mountpoint = "/nix";
                mountOptions = ["compress=zstd" "noatime" "discard=async"];
              };
              "@log" = {
                mountpoint = "/var/log";
                mountOptions = ["compress=zstd" "noatime" "discard=async"];
              };
            };
          };
        }

        {
          # p3：Vault 加密盘（LUKS2，解锁后 ext4，挂载 /mnt/vault），物理上位于 p1 与 p2 之间
          name = "VAULT";
          part-type = "primary";
          # 仅设置 MBR 类型码（0x83）；不是真的 ext4
          fs-type = "ext4";
          start = "1643890688s"; # 802.8672 GiB
          end = "1685833727s"; # 20 GiB
          #
          # ⚠️ 现有盘上【不要】打开下面这段，否则会重建 LUKS 容器（原数据不可恢复）：
          # content = {
          #   type = "luks";
          #   name = "vault";
          #   settings = { allowDiscards = true; };
          #   # 交互式输入口令；也可用 passwordFile = "/run/secrets/vault-pass";
          #   content = {
          #     type = "filesystem";
          #     format = "ext4";
          #     mountpoint = "/mnt/vault";
          #   };
          # };
        }
      ];
    };
  };
}
