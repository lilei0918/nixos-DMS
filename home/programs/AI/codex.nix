{pkgs, ...}: {
  # Codex - OpenAI AI coding agent（nixpkgs 声明式安装）
  # 原则：只安装工具，认证/模型由 codex 自行管理
  # 首次使用：codex login（或 codex --help）完成认证，凭据存 ~/.codex/（不进 Nix）
  # VSCodium 里的 Codex 扩展（Open VSX: openai.chatgpt）会自动使用 PATH 中的 codex CLI
  home.packages = with pkgs; [
    codex
  ];
}
