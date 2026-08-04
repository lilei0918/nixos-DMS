{pkgs, ...}: {
  ############################################
  # 加密数据盘 (LUKS, nvme0n1p3)
  #
  # 用途：密码库 + 个人文件（含 Vaultwarden 备份副本）
  # 策略：手动按需解锁，开机不自动挂载
  #   vault-open   输入密码解锁并挂载到 /mnt/vault
  #   vault-close  卸载并关闭加密卷
  #
  # LUKS UUID: 86c742fc-8de5-4c59-9a30-196484a35695
  ############################################

  # 挂载点目录（加密卷关闭时也保留，便于 mountpoint 检查）
  systemd.tmpfiles.rules = [
    "d /mnt/vault 0755 root root - -"
  ];

  environment.systemPackages = [
    (pkgs.writeShellApplication {
      name = "vault-open";

      runtimeInputs = [pkgs.cryptsetup pkgs.util-linux];

      text = ''
        set -euo pipefail

        if ! cryptsetup status vault >/dev/null 2>&1; then
          cryptsetup open "UUID=86c742fc-8de5-4c59-9a30-196484a35695" vault
        fi

        if ! mountpoint -q /mnt/vault; then
          mount /dev/mapper/vault /mnt/vault
        fi

        echo "vault open -> /mnt/vault"
      '';
    })

    (pkgs.writeShellApplication {
      name = "vault-close";

      runtimeInputs = [pkgs.cryptsetup pkgs.util-linux];

      text = ''
        set -euo pipefail

        if mountpoint -q /mnt/vault; then
          umount /mnt/vault
        fi

        if cryptsetup status vault >/dev/null 2>&1; then
          cryptsetup close vault
        fi

        echo "vault closed"
      '';
    })
  ];
}
