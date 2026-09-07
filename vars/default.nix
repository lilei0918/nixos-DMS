_: {
  # 用户信息（在 specialArgs 中注入，所有模块均可使用）
  username = "lilei";
  userfullname = "lilei";
  useremail = "lilei0918@gmail.com";

  # 用户主目录
  homeDirectory = "/home/lilei";

  # 本仓库路径（用于 shell 别名等）
  repoDir = "/home/lilei/nixos-DMS";

  # flake 输出名（用于 `nh os switch .#<flakeName>`）
  flakeName = "legion";

  # 独立显卡开关: false = 屏蔽独显(核显, 省电); true = 启用 NVIDIA 驱动(PRIME offload)
  # 平时核显输出, 游戏用 `nvidia-offload %command%` 走独显
  # 切换后 `nh os switch .#legion` 即生效
  enableNvidia = true;

  # 主题（GTK/Qt/光标统一从这里取值，见 home/programs/theme.nix、dconf.nix）
  #
  # GTK 用 Gruvbox Dark Medium（gruvbox-dark-gtk，jmattheis，目录名 gruvbox-dark）；
  # 图标用 WhiteSur-dark（whitesur-icon-theme）——其 Inherits=hicolor，能回退到各应用
  # 自带的品牌图标（google-chrome / zed 等），不会像 gruvbox 图标包那样缺图标。
  theme = {
    gtk = "gruvbox-dark";
    icon = "WhiteSur-dark";
    cursor = "macOS-White";
    cursorSize = 24;
  };
}
