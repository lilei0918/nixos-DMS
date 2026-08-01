{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # ─────────────────────────────
    # 🧰 系统基础工具
    # ─────────────────────────────

    wget
    curl

    git
    lazygit

    nh

    jq
    socat

    tree

    ripgrep
    fd
    bat
    eza

    # ─────────────────────────────
    # 🖥️ Terminal
    # ─────────────────────────────

    alacritty

    tmux

    starship

    fzf

    zoxide

    direnv

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

    grim

    slurp

    wl-clipboard

    wl-clip-persist

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
