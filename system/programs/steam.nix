{
  config,
  pkgs,
  ...
}: {
  # Mesa + Vulkan（含 32 位，Proton 必需）
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    # 如需工具可加：extraPackages = [ pkgs.vulkan-tools ];
  };

  programs.steam = {
    enable = true;
    # 直接内置 Proton-GE，兼容性更稳
    extraCompatPackages = [pkgs.proton-ge-bin];
    # 可选：本地网传/远程游玩端口
    # localNetworkGameTransfers.openFirewall = true;
  };

  # 性能/调试小工具（可选）
  programs.gamemode.enable = true;

  environment.systemPackages = with pkgs; [
    mangohud # 帧率叠加（可选）
    gamescope # 若遇到窗口化/全屏问题时好用（可选）
  ];

  # Wayland 下让 Steam 原生跑（可选）
  environment.sessionVariables.STEAM_USE_WAYLAND = "1";
}
