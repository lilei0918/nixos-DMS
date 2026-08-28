{pkgs, ...}: {
  ############################################
  # Steam
  ############################################

  programs.steam = {
    enable = true;

    package = pkgs.steam;

    # gamescope 会话: 用 GameScope 作为游戏容器, 修分辨率拉伸/向上采样
    gamescopeSession.enable = true;

    # protontricks: 对 Proton 游戏运行 Winetricks 命令
    protontricks.enable = true;

    # extest: 把 X11 输入事件翻译成 uinput (Wayland 下 Steam 手柄等输入)
    extest.enable = true;

    # Steam 中文界面需要的字体
    fontPackages = [pkgs.wqy_zenhei];
  };

  ############################################
  # GameMode (Feral Interactive)
  # 游戏运行时按需提升 CPU/GPU 频率
  ############################################

  programs.gamemode.enable = true;
}
