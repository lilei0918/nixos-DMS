{
  pkgs,
  myvars,
  ...
}: {
  # OpenCode - AI coding agent（nixpkgs 声明式安装）
  # 原则：只安装工具，provider/模型/凭据全部由 opencode 自行管理
  # 首次使用：opencode → /auth 或 opencode auth login（切换 Claude/OpenAI/Gemini/DeepSeek 无需改 Nix）

  # 权限规则：bash 默认 allow（日常低风险命令不再逐个确认），敏感文件 deny，高危命令 ask。
  # 策略说明见 agents/permissions.md；行为规则见仓库根目录 AGENTS.md。
  # 新增高危命令/敏感文件时，同步更新 agents/permissions.md。
  xdg.configFile."opencode/opencode.jsonc".text = ''
    {
      "$schema": "https://opencode.ai/config.json",
      // 火山方舟（Volcengine Ark）OpenAI 兼容端点。
      // 凭据不写进仓库：provider 从服务进程环境的 ARK_API_KEY 读取。
      // 设置方式（任选）：opencode service set env ARK_API_KEY 'ark-...'
      //                   或 opencode auth login ark --method key
      "providers": {
        "ark": {
          "name": "Volcengine Ark",
          "env": ["ARK_API_KEY"],
          "package": "@opencode/ai/providers/openai-compatible",
          "settings": {
            "baseURL": "https://ark.cn-beijing.volces.com/api/v3"
          },
          "models": {
            "deepseek-v4-1-flash-economy-261017": {
              "name": "DeepSeek V4.1 Flash Economy (Ark)",
              "tool_call": true,
              "limit": { "context": 131072, "output": 8192 }
            }
          }
        }
      },
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
        "edit": {
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
          "*": "allow",
          "sudo*": "ask",
          "rm*": "ask",
          "nh os switch*": "ask",
          "nh os boot*": "ask",
          "vault-open*": "ask",
          "vault-close*": "ask",
          "sops*": "ask",
          "cryptsetup*": "ask",
          "git push*": "ask",
          "gh pr create*": "ask",
          "gh issue create*": "ask",
          "gh repo create*": "ask",
          "nixos-rebuild switch*": "ask",
          "nixos-rebuild boot*": "ask",
          "env*": "ask",
          "printenv*": "ask",
          "mount*": "ask",
          "umount*": "ask",
          "mkfs*": "ask",
          "fdisk*": "ask",
          "parted*": "ask",
          "dd*": "ask",
          "shutdown*": "ask",
          "reboot*": "ask",
          "poweroff*": "ask"
        }
      }
    }
  '';

  home.packages = with pkgs; [
    opencode
  ];
}
