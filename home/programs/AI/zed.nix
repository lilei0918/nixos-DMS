{pkgs, ...}: {
  # Zed 编辑器（nixpkgs 包，二进制名 zeditor）
  # 原则：设置/插件清单/主题全部声明式；API key/登录走 Zed keychain（不进 Nix）
  home.packages = with pkgs; [
    zed-editor
    nixd # Nix 语言服务器（Zed 的 Nix 扩展需要，否则提示 nixd not available）
  ];

  home.file.".config/zed/settings.json".text = builtins.toJSON {
    # =========================
    # Theme
    # =========================
    # macOS Classic 主题（来自 macos-classic 插件，auto_install_extensions 自动安装）
    # 官方推荐配置：跟随系统亮/暗模式自动切换
    # （参考 https://github.com/huacnlee/zed-theme-macos-classic README Usage 部分）
    theme = {
      mode = "system";
      light = "macOS Classic Light";
      dark = "macOS Classic Dark";
    };

    # =========================
    # 插件自动安装清单（Zed 首次启动自动安装）
    # 新增插件：在 Zed 里安装后，把插件名加到下面即可声明式管理
    # =========================
    auto_install_extensions = {
      "catppuccin-icons" = true;
      "git-firefly" = true;
      "html" = true;
      "macos-classic" = true;
      "nix" = true;
    };

    # =========================
    # Editor
    # =========================
    vim_mode = true;
    minimap = {
      # Zed 的 minimap.show 是字符串枚举，不是 boolean！
      # 合法值："never" / "always" / "auto"（false 会报类型错误）
      show = "never";
    };

    # =========================
    # Terminal
    # =========================
    terminal = {
      # 合法格式：对象（program / with_arguments）或 "system"
      # 不能用裸字符串 "fish"（会导致 settings 解析报错）
      shell = {
        program = "fish";
      };
    };

    # =========================
    # ACP agent 服务器（External Agents）
    # =========================
    # opencode 支持 ACP（`opencode acp` 是标准 ACP server，stdio 协议）。
    # ⚠️ 不要用 `opencode serve`（那是 HTTP 服务器，Zed 连不上会一直 loading）！
    # 官方格式（zed.dev/docs/ai/external-agents）：
    #   { "agent_servers": { "<id>": { "type": "custom", "command": ..., "args": [...], "env": {} } } }
    agent_servers = {
      opencode = {
        type = "custom";
        command = "opencode";
        args = [
          "acp"
        ];
        env = {};
      };
    };
  };
}
