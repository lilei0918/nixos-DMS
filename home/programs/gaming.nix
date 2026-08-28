{pkgs, ...}: {
  home.packages = with pkgs; [
    # ─────────────────────────────
    # 🎮 游戏监控 / 优化
    # ─────────────────────────────

    mangohud # FPS/温度/CPU/GPU 占用 overlay
    gamescope # 游戏微合成器（修分辨率拉伸、限帧）
    gamemode # GameMode 客户端库（配合系统层 programs.gamemode）

    # ─────────────────────────────
    # 🕹️ Wine / Proton 工具
    # ─────────────────────────────

    protonplus # 安装自定义 Proton 版本（如 GE-Proton）的 GUI
    winetricks # 为 Wine 安装各种运行库
    umu-launcher # 统一的 Windows 游戏启动器（Wine/Proton）

    # ─────────────────────────────
    # 🎮 游戏启动器
    # ─────────────────────────────

    heroic # Epic / GOG 游戏启动器
    lutris # 全平台游戏启动器

    # ─────────────────────────────
    # 🔧 其他
    # ─────────────────────────────

    bbe # Sed 式二进制编辑器（部分游戏修 bug 用）
  ];
}
