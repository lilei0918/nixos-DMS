{pkgs, ...}: {
  # OpenCode - AI coding agent（nixpkgs 声明式安装）
  # 原则：只安装工具，provider/模型/凭据全部由 opencode 自行管理
  # 首次使用：opencode → /auth 或 opencode auth login（切换 Claude/OpenAI/Gemini/DeepSeek 无需改 Nix）
  home.packages = with pkgs; [
    opencode
  ];
}
