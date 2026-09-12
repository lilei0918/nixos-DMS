{pkgs, ...}: {
  # ============================================================================
  # Zed + 开发工具
  # ============================================================================

  home.packages = with pkgs; [
    # --------------------------------------------------------------------------
    # Python
    # --------------------------------------------------------------------------
    ruff
    ty

    # --------------------------------------------------------------------------
    # Rust
    # --------------------------------------------------------------------------
    rust-analyzer

    # --------------------------------------------------------------------------
    # Go
    # --------------------------------------------------------------------------
    gopls

    # --------------------------------------------------------------------------
    # Nix
    # --------------------------------------------------------------------------
    nixfmt

    # --------------------------------------------------------------------------
    # JavaScript / TypeScript
    # --------------------------------------------------------------------------
    # vtsls 与 typescript-language-server 二选一；用后者（自带 tsserver 依赖）
    typescript-language-server

    # 统一格式化（TS/JS/JSON/Markdown 等，见 languages.*.formatter.external）
    prettier
  ];

  # ============================================================================
  # Zed
  # ============================================================================

  programs.zed-editor = {
    enable = true;

    # 完全由 Nix 管理 Zed 配置
    mutableUserSettings = false;
    mutableUserKeymaps = false;

    userSettings = {
      # ========================================================================
      # 基础编辑器
      # ========================================================================

      # 不使用 Vim 模式
      vim_mode = false;

      # VS Code 风格快捷键
      base_keymap = "VSCode";

      # UI 字体
      ui_font_family = "Inter";
      ui_font_size = 18;

      # 中文回退：霞鹜文楷 屏幕阅读版（lxgw-wenkai-screen，见 system/fonts.nix）
      ui_font_fallbacks = ["LXGW WenKai Screen"];

      # 编辑器字体
      buffer_font_family = "JetBrainsMono Nerd Font";
      buffer_font_size = 16;

      # 中文回退：霞鹜文楷 屏幕阅读版（与 UI 同）
      buffer_font_fallbacks = ["LXGW WenKai Screen"];

      # Agent UI
      agent_ui_font_family = "Inter";
      agent_ui_font_size = 18;

      # Agent 输入区
      agent_buffer_font_family = "JetBrainsMono Nerd Font";
      agent_buffer_font_size = 17;

      # ========================================================================
      # Theme
      # ========================================================================

      # Gruvbox 对长时间编码比较友好
      #
      # Zed 内置 "Gruvbox Dark" 即 Medium 对比（编辑器底色 #282828，
      # 比 Dark Hard 的 #1d2021 柔和）。整机统一固定 Dark，不跟随系统。
      theme = {
        mode = "dark";
        light = "Gruvbox Light";
        dark = "Gruvbox Dark";
      };

      # ========================================================================
      # Icon Theme
      #
      # 扩展 `icons-modern-material` 提供（Material 风格）；
      # Zed 的 icon_theme 是字符串（不是 theme 那样的 mode/light/dark 对象）。
      # ========================================================================

      icon_theme = "Icons modern material (Dark)";

      # ========================================================================
      # Layout
      #
      # 三栏：
      #
      # LEFT   = Project Explorer（文件夹树）
      # CENTER = Editor（代码区）
      # RIGHT  = OpenCode Agent Panel（ACP，右侧对话框）
      # BOTTOM = Terminal（辅助，Ctrl+` 按需打开，不参与三栏）
      # ========================================================================

      # ------------------------------------------------------------------------
      # Project Explorer
      # ------------------------------------------------------------------------

      project_panel = {
        # 左侧
        dock = "left";

        # 宽度
        default_width = 280;

        # 更适合长期使用
        entry_spacing = "comfortable";

        # Git 文件状态
        git_status = true;

        # 打开项目时自动显示
        starts_open = true;

        # 编辑文件时自动定位到 Explorer
        auto_reveal_entries = true;

        # 自动折叠只有一个子目录的目录链
        auto_fold_dirs = true;

        # 显示项目根目录
        hide_root = false;

        # 显示隐藏文件
        hide_hidden = false;

        # 粘性目录
        sticky_scroll = true;

        # 显示诊断信息
        show_diagnostics = "all";

        # 缩进线
        indent_guides = {
          show = "always";
        };

        # 目录优先
        sort_mode = "directories_first";

        # 滚动条
        scrollbar = {
          show = null;
          horizontal_scroll = true;
        };
      };

      # ------------------------------------------------------------------------
      # AI Agent
      # ------------------------------------------------------------------------

      agent = {
        # 启用 Agent
        enabled = true;

        # 显示 Agent 按钮
        button = true;

        # 右侧
        dock = "right";

        # 右侧宽度
        #
        # 420 对 16:9 / 2.5K 屏幕比较合适。
        # 如果你觉得 AI 区域太宽，可以改成 380。
        default_width = 420;

        # 如果 Agent 被放到底部时使用
        default_height = 600;
      };

      # ------------------------------------------------------------------------
      # Terminal
      # ------------------------------------------------------------------------

      terminal = {
        # 辅助终端放底部，不参与右侧三栏布局
        dock = "bottom";

        # 底部高度
        default_height = 320;

        # 需要时 Ctrl+` 手动打开
        starts_open = false;

        # Fish
        shell = {
          program = "fish";
        };
      };

      # ------------------------------------------------------------------------
      # Dock resize
      #
      # 左（Project）与右（Agent）宽度独立调整即可；
      # 底部 Terminal 单独调整，不参与联动。
      # ------------------------------------------------------------------------

      resize_all_panels_in_dock = [
        "left"
        "right"
      ];

      # ========================================================================
      # Editor
      # ========================================================================

      # 自动保存
      autosave = "on_focus_change";

      # 自动显示函数签名
      auto_signature_help = true;

      # LSP 请求超时
      completions = {
        lsp_fetch_timeout_ms = 2000;
      };

      # ------------------------------------------------------------------------
      # Minimap
      # ------------------------------------------------------------------------

      minimap = {
        show = "never";
      };

      # ------------------------------------------------------------------------
      # Inlay Hints
      # ------------------------------------------------------------------------

      inlay_hints = {
        enabled = true;
      };

      # ------------------------------------------------------------------------
      # Line numbers
      #
      # 不使用 Vim 后，相对行号意义没那么大。
      # 使用普通行号更接近 VS Code / VSCodium。
      # ------------------------------------------------------------------------

      relative_line_numbers = "disabled";

      # ------------------------------------------------------------------------
      # Scroll
      # ------------------------------------------------------------------------

      vertical_scroll_margin = 5;

      # 编辑器软换行
      soft_wrap = "editor_width";

      # ------------------------------------------------------------------------
      # Indent
      # ------------------------------------------------------------------------

      indent_guides = {
        enabled = true;
        coloring = "indent_aware";
      };

      # ========================================================================
      # Search
      # ========================================================================

      # 正则搜索
      search = {
        regex = true;
        case_sensitive = false;
        whole_word = false;
      };

      # 智能大小写
      search_wrap = true;

      # ========================================================================
      # Git
      # ========================================================================

      git = {
        inline_blame = {
          enabled = true;
        };
      };

      # Tab 显示 Git 状态
      tabs = {
        git_status = true;
      };

      # ========================================================================
      # Telemetry / Privacy
      # ========================================================================

      telemetry = {
        diagnostics = false;
        metrics = false;
      };

      # 编辑预测数据
      edit_predictions = {
        mode = "subtle";
      };

      # ========================================================================
      # Python
      # ========================================================================

      languages = {
        # ----------------------------------------------------------------------
        # Python
        # ----------------------------------------------------------------------

        Python = {
          language_servers = [
            "ty"
            "ruff"
            "!basedpyright"
            "!pyrefly"
            "!pyright"
            "!pylsp"
          ];

          formatter = {
            language_server = {
              name = "ruff";
            };
          };

          format_on_save = "on";

          # Python 缩进
          tab_size = 4;
          hard_tabs = false;
        };

        # ----------------------------------------------------------------------
        # Rust
        # ----------------------------------------------------------------------

        Rust = {
          language_servers = [
            "rust-analyzer"
            "!rustc"
          ];

          formatter = {
            language_server = {
              name = "rust-analyzer";
            };
          };

          format_on_save = "on";
        };

        # ----------------------------------------------------------------------
        # Go
        # ----------------------------------------------------------------------

        Go = {
          language_servers = [
            "gopls"
            "!goimports"
          ];

          formatter = {
            language_server = {
              name = "gopls";
            };
          };

          format_on_save = "on";
        };

        # ----------------------------------------------------------------------
        # Nix
        # ----------------------------------------------------------------------

        Nix = {
          language_servers = [
            "nil"
          ];

          formatter = {
            external = {
              command = "nixfmt";
              arguments = [
                "--filename"
                "{buffer_path}"
              ];
            };
          };

          format_on_save = "on";
        };

        # ----------------------------------------------------------------------
        # TypeScript / JavaScript
        # LSP = typescript-language-server；格式化交给 prettier（LSP 不负责格式化）
        # ----------------------------------------------------------------------

        TypeScript = {
          language_servers = [
            "typescript-language-server"
          ];

          formatter = {
            external = {
              command = "prettier";
              arguments = [
                "--stdin-filepath"
                "{buffer_path}"
              ];
            };
          };

          format_on_save = "on";

          tab_size = 2;
          hard_tabs = false;
        };

        JavaScript = {
          language_servers = [
            "typescript-language-server"
          ];

          formatter = {
            external = {
              command = "prettier";
              arguments = [
                "--stdin-filepath"
                "{buffer_path}"
              ];
            };
          };

          format_on_save = "on";

          tab_size = 2;
          hard_tabs = false;
        };

        # ----------------------------------------------------------------------
        # JSON / Markdown：prettier
        # ----------------------------------------------------------------------

        JSON = {
          formatter = {
            external = {
              command = "prettier";
              arguments = [
                "--stdin-filepath"
                "{buffer_path}"
              ];
            };
          };

          format_on_save = "on";

          tab_size = 2;
          hard_tabs = false;
        };

        Markdown = {
          formatter = {
            external = {
              command = "prettier";
              arguments = [
                "--stdin-filepath"
                "{buffer_path}"
              ];
            };
          };

          format_on_save = "on";

          soft_wrap = "editor_width";
          tab_size = 2;
          hard_tabs = false;
        };
      };

      # ========================================================================
      # External AI Agents / ACP
      #
      # API Key / 登录信息不要写进 Nix。
      # 由各个 Agent 自己管理认证。
      # ========================================================================

      agent_servers = {
        # ----------------------------------------------------------------------
        # OpenCode
        # ----------------------------------------------------------------------

        opencode = {
          type = "custom";

          command = "opencode";

          args = [
            "acp"
          ];

          env = {};
        };

        # ----------------------------------------------------------------------
        # Cursor
        # ----------------------------------------------------------------------

        cursor = {
          type = "registry";
        };

        # ----------------------------------------------------------------------
        # Codex
        # ----------------------------------------------------------------------

        codex-acp = {
          type = "registry";
        };

        # ----------------------------------------------------------------------
        # Claude
        # ----------------------------------------------------------------------

        claude-acp = {
          type = "registry";
        };
      };
    };

    # ========================================================================
    # Zed Extensions
    # ========================================================================

    extensions = [
      # Material 风格文件/文件夹图标（icon_theme 见上）
      "icons-modern-material"

      # Git
      "git-firefly"

      # HTML
      "html"

      # Nix
      "nix"

      # TOML（taplo LSP）
      "toml"

      # Dockerfile
      "dockerfile"

      # SQL
      "sql"
    ];

    # ========================================================================
    # 快捷键（VS Code 风格补充；base_keymap = "VSCode" 已覆盖大部分）
    # ========================================================================

    userKeymaps = [
      {
        bindings = {
          "ctrl-p" = "file_finder::Toggle";
        };
      }

      {
        bindings = {
          "ctrl-shift-f" = "pane::DeploySearch";
        };
      }

      {
        bindings = {
          "ctrl-b" = "project_panel::ToggleFocus";
        };
      }

      {
        bindings = {
          "ctrl-shift-e" = "project_panel::ToggleFocus";
        };
      }

      {
        bindings = {
          "ctrl-shift-g" = "git_panel::ToggleFocus";
        };
      }

      {
        bindings = {
          "ctrl-j" = "terminal_panel::ToggleFocus";
        };
      }
    ];
  };
}
