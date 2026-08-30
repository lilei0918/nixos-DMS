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
  theme = {
    gtk = "WhiteSur-Dark";
    icon = "WhiteSur";
    cursor = "macOS-White";
    cursorSize = 24;
  };
}
