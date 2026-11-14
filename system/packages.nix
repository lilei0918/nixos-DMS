{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # ─────────────────────────────
    # 🧰 系统基础工具
    # ─────────────────────────────

    wget
    curl

    # gio/gdbus：xdg-open 在 niri 等非主流桌面下走 `gio open` 分发 URL，
    # 自定义协议（x-scheme-handler）回调依赖它
    glib

    # git 由 home/programs/git.nix（programs.git.enable）安装，避免双装
    lazygit

    nh

    jq
    socat

    tree

    ripgrep
    fd
    bat
    eza

    yazi
    superfile

    # ─────────────────────────────
    # 🖥️ Terminal
    # 说明：alacritty/tmux/starship/direnv 由 home 模块（programs.*.enable）安装，
    # 这里只保留仅系统级的 fzf/zoxide（fish/zsh 只 source，不装包）
    # ─────────────────────────────

    fzf

    zoxide

    # ─────────────────────────────
    # 🧩 桌面壳（Wayland）
    # ─────────────────────────────

    noctalia # bar / launcher / control-center / 通知（替代 DMS，niri 里 spawn-at-startup 启动）

    # ─────────────────────────────
    # 📦 压缩 / 解压
    # ─────────────────────────────

    zip
    unzip

    p7zip

    rar

    dtrx

    # ─────────────────────────────
    # 💻 Nix 开发工具
    # ─────────────────────────────

    nil

    alejandra

    statix

    deadnix

    nix-tree

    nix-output-monitor

    sops

    age

    # ─────────────────────────────
    # 🔨 编译工具
    # ─────────────────────────────

    gcc

    gnumake

    # ─────────────────────────────
    # 🖥️ Wayland / Niri
    # ─────────────────────────────

    xwayland

    xwayland-satellite

    wl-clipboard

    # ─────────────────────────────
    # 🔍 硬件检测
    # ─────────────────────────────

    pciutils

    ddcutil

    # ─────────────────────────────
    # 💾 文件系统
    # ─────────────────────────────

    btrfs-progs

    ntfs3g

    # ─────────────────────────────
    # 🌐 网络兼容
    # ─────────────────────────────

    wsdd

    # ─────────────────────────────
    # 🔐 Secret
    # ─────────────────────────────

    libsecret

    # ─────────────────────────────
    # 📱 Android 调试（adb）
    # ─────────────────────────────

    android-tools

    # ─────────────────────────────
    # 📦 AppImage
    # ─────────────────────────────

    # 运行 AppImage 文件：appimage-run xxx.AppImage
    # 但部分 AppImage（如 longbridge）依赖系统库（webkit），沙箱里没有。
    # 需在 nix-ld 环境下直跑，见 system/nix-ld.nix。
    appimage-run

    # ─────────────────────────────
    # 🎧 系统控制
    # ─────────────────────────────

    playerctl

    brightnessctl

    libnotify

    # ─────────────────────────────
    # 编辑器
    # ─────────────────────────────

    vim

    gnome-text-editor
  ];
}
