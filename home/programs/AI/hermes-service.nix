{config, ...}: {
  # Hermes Agent 系统服务（NixOS 模块）。
  # 说明：`services.hermes-agent` 是 systemd 系统服务（hermes 用户运行网关），
  # 只能在 NixOS 上下文设置，故本文件经 hosts/legion/configuration.nix 导入，
  # 与 home-manager 的 hermes.nix（桌面入口）物理同处 AI 目录集中管理。
  # 桌面 CLI/GUI 安装：home/programs/AI/hermes.nix。

  services."hermes-agent" = {
    enable = true;

    settings = {
      model.default = "deepseek-v4-flash"; # 改为你的模型
      toolsets = ["all"];
      terminal = {
        backend = "local";
        timeout = 180;
      };

      # 本地模型：macOS 笔记本上的 OpenAI 兼容端点（dogfoodai 自托管）
      providers."mac-local" = {
        name = "Mac Local (Qwen)";
        api = "http://192.168.0.100:8000/v1";
        transport = "openai_chat";
        models = [
          "dogfoodai/Qwen3.8-27B-4bit"
        ];
      };
    };

    environmentFiles = [
      config.sops.templates."hermes-env".path
    ];

    addToSystemPackages = true;
  };

  # Hermes 环境变量模板（DEEPSEEK_API_KEY 由 sops 解密注入）
  sops.templates."hermes-env" = {
    content = ''

      DEEPSEEK_API_KEY=${config.sops.placeholder."deepseek_api_key"}

    '';
  };

  # 修复：auth.json 若属主是交互用户（lilei）则服务（hermes 用户）无法读取。
  # tmpfiles 规则在启动时把属主统一为 hermes:hermes（权限保持 600 属主可读写）。
  systemd.tmpfiles.rules = [
    "f /var/lib/hermes/.hermes/auth.json 0600 hermes hermes - -"
  ];

  # 修复：网关排空（drain）需要更长停止超时。
  # 上游模块未设置 TimeoutStopSec，systemd 默认 10s 会在网关排空时 SIGKILL。
  systemd.services."hermes-agent".serviceConfig.TimeoutStopSec = 30;
}
