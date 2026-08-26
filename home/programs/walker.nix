{pkgs, ...}: {
  home.packages = with pkgs; [
    walker
  ];

  # elephant（walker 的 provider 守护进程，剪贴板历史依赖）走 HM 模块：
  # 替代原手写 systemd.user.services.elephant，由模块生成正确的用户服务与依赖
  services.elephant.enable = true;

  # 可选：自定义 walker 配置
  # home.file.".config/walker/config.json".text = builtins.toJSON {
  #   clipboard.enable = true;
  # };
}
