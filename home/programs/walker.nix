{
  config,
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    walker
    elephant # 剪贴板历史依赖
  ];

  systemd.user.services.elephant = {
    Unit.Description = "Elephant Service for Walker";
    # 关键：明确要求此服务在 graphical-session.target 之后启动
    Unit.After = ["graphical-session.target"];
    Unit.PartOf = ["graphical-session.target"];

    Service = {
      Type = "simple";
      # 使用 elephant 的可执行文件路径
      ExecStart = "${pkgs.elephant}/bin/elephant";
      Restart = "on-failure";
      RestartSec = 3;
    };

    Install.WantedBy = ["graphical-session.target"];
  };
  # 可选：自定义 walker 配置
  # home.file.".config/walker/config.json".text = builtins.toJSON {
  #   clipboard.enable = true;
  # };
}
