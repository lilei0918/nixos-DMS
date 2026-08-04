{pkgs, ...}: {
  # Pi - AI coding agent（nixpkgs 声明式安装）
  # 原则：只安装工具，认证/模型由 pi 自行管理
  # 首次使用：pi → /login（选择 provider 并登录）；配置自动写入 ~/.pi/agent/auth.json
  # 自定义 provider 才需要 ~/.pi/agent/models.json（pi 自动创建，Nix 不干预）
  home.packages = with pkgs; [
    pi-coding-agent
  ];
}
