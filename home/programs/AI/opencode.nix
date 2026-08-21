{
  pkgs,
  myvars,
  ...
}: {
  # OpenCode - AI coding agent（nixpkgs 声明式安装）
  # 原则：只安装工具，provider/模型/凭据全部由 opencode 自行管理
  # 首次使用：opencode → /auth 或 opencode auth login（切换 Claude/OpenAI/Gemini/DeepSeek 无需改 Nix）

  # 权限规则：默认 ask，只放行只读/安全检查命令；敏感文件与高危命令需确认。
  # 策略说明见 agents/permissions.md；行为规则见仓库根目录 AGENTS.md。
  # 新增高危命令/敏感文件时，同步更新 agents/permissions.md。
  xdg.configFile."opencode/opencode.jsonc".text = ''
    {
      "$schema": "https://opencode.ai/config.json",
      "permission": {
        "read": {
          "*": "allow",
          "secrets/**": "deny",
          "*.key": "deny",
          "*.pem": "deny",
          "*.env": "deny",
          "*.env.*": "deny",
          ".ssh/**": "deny",
          ".gnupg/**": "deny",
          ".aws/**": "deny",
          ".kube/**": "deny",
          "~/.config/mihomo/**": "deny",
          "${myvars.homeDirectory}/.config/mihomo/**": "deny"
        },
        "edit": "allow",
        "glob": "allow",
        "grep": "allow",
        "task": "ask",
        "lsp": "allow",
        "skill": "allow",
        "question": "allow",
        "todowrite": "allow",
        "webfetch": "allow",
        "external_directory": "ask",
        "doom_loop": "deny",
        "bash": {
          "*": "ask",
          "git status*": "allow",
          "git diff*": "allow",
          "git log*": "allow",
          "git show*": "allow",
          "git branch*": "allow",
          "git remote*": "allow",
          "git tag*": "allow",
          "git blame*": "allow",
          "git reflog*": "allow",
          "git stash list*": "allow",
          "git lfs*": "allow",
          "gh repo view*": "allow",
          "gh issue view*": "allow",
          "gh pr view*": "allow",
          "gh api*": "allow",
          "gh search*": "allow",
          "nix eval*": "allow",
          "nix build*": "allow",
          "nix flake*": "allow",
          "nix profile*": "allow",
          "nix store*": "allow",
          "nix search*": "allow",
          "nix doctor*": "allow",
          "nixos-rebuild build*": "allow",
          "nh os test*": "allow",
          "alejandra*": "allow",
          "statix check*": "allow",
          "deadnix*": "allow",
          "systemctl status*": "allow",
          "systemctl list-*": "allow",
          "systemctl show*": "allow",
          "journalctl*": "allow",
          "lsblk*": "allow",
          "df*": "allow",
          "free*": "allow",
          "uptime*": "allow",
          "uname*": "allow",
          "lspci*": "allow",
          "lsusb*": "allow",
          "sensors*": "allow",
          "lsof*": "allow",
          "rg*": "allow",
          "fd*": "allow",
          "ls*": "allow",
          "cat*": "allow",
          "head*": "allow",
          "tail*": "allow",
          "wc*": "allow",
          "find*": "allow",
          "which*": "allow",
          "echo*": "allow",
          "pwd*": "allow",
          "date*": "allow",
          "env*": "ask",
          "printenv*": "ask",
          "file*": "allow",
          "stat*": "allow",
          "du*": "allow",
          "tree*": "allow",
          "bat*": "allow",
          "eza*": "allow",
          "jq*": "allow",
          "yq*": "allow",
          "mkdir*": "allow",
          "rmdir*": "allow",
          "grep*": "allow",
          "cp*": "allow",
          "mv*": "allow",
          "chmod*": "allow",
          "rm*": "ask",
          "rm -rf*": "ask",
          "sudo*": "ask",
          "nh os switch*": "ask",
          "nh os boot*": "ask",
          "vault-open*": "ask",
          "vault-close*": "ask",
          "sops*": "ask",
          "cryptsetup*": "ask"
        }
      }
    }
  '';

  home.packages = with pkgs; [
    opencode
  ];
}
