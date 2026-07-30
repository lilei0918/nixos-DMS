{
  config,
  pkgs,
  inputs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    # 🧰 常用工具
    wget
    git
    pavucontrol
    xwayland
    nh
    pciutils # 查看 OpenGL 信息
    ddcutil
    grim
    slurp

    # 🎨 桌面美化
    waypaper
    apple-cursor

    # 🔊 多媒体支持

    playerctl
    spicetify-cli

    # 🌐 Node 工具
    #nodePackages.prettier

    wsdd # gvfs 里启用了 Windows 网络发现
    libsecret

    # 🧪 预留模块（注释留用）
    #arrpc
    #alvr
    #mesa（已启用）
    #brillo
  ];
}
