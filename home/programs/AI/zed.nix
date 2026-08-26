{pkgs, ...}: {
  # Zed 编辑器（HM 官方模块 programs.zed-editor，二进制名 zeditor）
  # 原则：设置/插件清单/主题全部声明式；API key/登录走 Zed keychain（不进 Nix）
  # nixd（Nix LSP）统一在 vscode.nix 的 home.packages 安装（同一 profile，PATH 共享）

  # LSP 二进制经 Nix 进 PATH，避免 Zed 弹窗自动下载到 ~/.local/share/zed（非声明式）
  home.packages = with pkgs; [
    gopls
    ruff
    rust-analyzer
    ty
  ];

  programs.zed-editor = {
    enable = true;

    # false = 完全声明式：Zed UI 里改 settings 会在下次 switch 被覆盖
    # （想保留 UI 临时改动可改为 true，Nix 配置仍作为基线）
    mutableUserSettings = false;
    mutableUserKeymaps = false;

    userSettings = {
      # =========================
      # Theme
      # =========================
      # macOS Classic 主题（来自 macos-classic 插件，extensions 自动安装）
      # 官方推荐配置：跟随系统亮/暗模式自动切换
      # （参考 https://github.com/huacnlee/zed-theme-macos-classic README Usage 部分）
      theme = {
        mode = "system";
        light = "macOS Classic Light";
        dark = "macOS Classic Dark";
      };

      # =========================
      # Editor
      # =========================
      vim_mode = true;
      minimap = {
        # Zed 的 minimap.show 是字符串枚举，不是 boolean！
        # 合法值："never" / "always" / "auto"（false 会报类型错误）
        show = "auto";
      };

      # 编辑器行为（参考 ryan4yin/nix-config zed-editor.nix）
      auto_signature_help = true;
      autosave = "on_focus_change";
      code_lens = "on";
      completions.lsp_fetch_timeout_ms = 2000;
      diagnostics.inline.enabled = true;
      inlay_hints.enabled = true;
      relative_line_numbers = "enabled";
      soft_wrap = "editor_width";
      vertical_scroll_margin = 5.0;
      which_key.enabled = true;
      indent_guides = {
        background_coloring = "indent_aware";
        coloring = "indent_aware";
      };

      # =========================
      # Search
      # =========================
      search.regex = true;
      use_smartcase_search = true;

      # =========================
      # UI chrome / Git
      # =========================
      tabs.git_status = true;
      title_bar.show_branch_status_icon = true;
      git.inline_blame.show_commit_summary = true;

      # =========================
      # 隐私（关闭遥测与数据收集）
      # =========================
      edit_predictions.allow_data_collection = "no";
      telemetry = {
        diagnostics = false;
        metrics = false;
      };

      # =========================
      # Fonts
      # =========================
      # 用系统已装字体：等宽 JetBrainsMono Nerd Font，UI 走 Inter
      ui_font_family = "Inter";
      ui_font_size = 16.0;
      buffer_font_family = "JetBrainsMono Nerd Font";
      buffer_font_size = 14.0;
      agent_ui_font_size = 16.0;
      agent_buffer_font_size = 15.0;

      # =========================
      # Language-specific LSP / formatter
      # =========================
      # `!xxx` 表示禁用对应 LSP；formatter 走 language_server
      languages = {
        Python = {
          formatter.language_server.name = "ruff";
          language_servers = [
            "ty"
            "ruff"
            "!basedpyright"
            "!pyrefly"
            "!pyright"
            "!pylsp"
          ];
        };
        Rust = {
          hard_tabs = false;
          formatter.language_server.name = "rust-analyzer";
          language_servers = [
            "rust-analyzer"
            "!rustc"
          ];
        };
        Go = {
          formatter.language_server.name = "gopls";
          language_servers = [
            "gopls"
            "!goimports"
          ];
        };
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
        # registry 方式一键启用（Zed 自动解析启动命令）
        cursor.type = "registry";
        codex-acp.type = "registry";
        claude-acp.type = "registry";
      };
    };

    # 插件自动安装清单（模块管理，等价于手写 auto_install_extensions）
    # 新增插件：在 Zed 里安装后，把插件名加到这里即可声明式管理
    extensions = [
      "catppuccin-icons"
      "git-firefly"
      "html"
      "macos-classic"
      "nix"
    ];
  };
}
