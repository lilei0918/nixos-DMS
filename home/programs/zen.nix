{inputs, ...}: {
  imports = [
    inputs.zen-browser.homeModules.twilight
  ];

  # ============================================================
  # Zen Browser（twilight 变体，可复现）
  #
  # 与 Chrome 并存：不设为默认浏览器（Chrome 仍是 super+b / 默认），
  # 需要时用 zen-twilight 启动或从应用菜单打开。
  # 主题与整机统一为 Gruvbox Dark Medium（见 vars/default.nix）：
  #   - 浏览器 UI：userChrome.css 覆写为 Gruvbox 色板
  #   - 网页：强制 content 走 prefers-color-scheme: dark（绝大多数站点自适配暗色），
  #     Dark Reader 兜底对不支持的站点强制重绘
  #   - 常用插件：经 policies 从 AMO 声明式安装（normal_installed，用户可禁用/卸载）
  # ============================================================

  programs.zen-browser = {
    enable = true;

    policies = {
      # 更新由 flake input 管理（该 flake 默认已禁用浏览器内更新检查）
      DisableAppUpdate = true;

      # 隐私：遥测 / 研究 / Pocket / 默认浏览器检查
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DontCheckDefaultBrowser = true;

      # 登录提示与默认书签
      OfferToSaveLogins = false;
      NoDefaultBookmarks = true;

      # 常用插件（AMO 声明式安装，normal_installed 用户可自管）
      ExtensionSettings = {
        # uBlock Origin（广告/跟踪拦截）
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "normal_installed";
        };
        # SponsorBlock（跳过赞助片段）
        "sponsorBlocker@ajay.app" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
          installation_mode = "normal_installed";
        };
        # Dark Reader（不自动适配暗色的站点兜底；默认安装即启用）。
        # ⚠️ 其配色只能在其设置面板调整（无 storage.managed，Nix 无法注入），
        #    详见下方 userContent 注释。
        "addon@darkreader.org" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
          installation_mode = "normal_installed";
        };
      };
    };

    profiles.default = {
      # 网页也走暗色：UI 与 content 均报告 dark；未适配站点由 Dark Reader 兜底
      settings = {
        # 让 userChrome.css / userContent.css 生效
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

        "ui.systemUsesDarkTheme" = true;
        "layout.css.prefers-color-scheme.content-override" = 1; # 0=light 1=dark 2=system
      };

      # 浏览器 chrome（UI）涂成 Gruvbox Dark Medium（#282828 系）
      userChrome = ''
        :root {
          color-scheme: dark !important;
          --gruvbox-bg0_h: #1d2021;
          --gruvbox-bg0: #282828;
          --gruvbox-bg1: #3c3836;
          --gruvbox-bg2: #504945;
          --gruvbox-bg3: #665c54;
          --gruvbox-fg: #ebdbb2;
          --gruvbox-fg1: #fbf1c7;
          --gruvbox-gray: #a89984;
          --gruvbox-blue: #83a598;
          --gruvbox-green: #b8bb26;
          --gruvbox-yellow: #fabd2f;
          --gruvbox-red: #fb4934;
          --zen-main-browser-background: var(--gruvbox-bg0) !important;
          --toolbarbutton-icon-fill: var(--gruvbox-fg) !important;
        }

        #main-window,
        #navigator-toolbox,
        #titlebar,
        #TabsToolbar,
        #zen-tabbox-wrapper,
        browser {
          background-color: var(--gruvbox-bg0) !important;
        }

        /* 标签页 */
        .tabbrowser-tab .tab-background {
          background-color: transparent !important;
        }
        .tabbrowser-tab:is([selected], [multiselected]) .tab-background {
          background-color: var(--gruvbox-bg1) !important;
          box-shadow: 0 0 0 1px var(--gruvbox-bg2) !important;
        }
        .tabbrowser-tab:hover > .tab-stack > .tab-background {
          background-color: var(--gruvbox-bg2) !important;
        }
        .tabbrowser-tab .tab-label,
        .tab-icon-image {
          color: var(--gruvbox-fg) !important;
        }

        /* 地址栏 */
        #urlbar,
        #urlbar-background {
          background-color: var(--gruvbox-bg1) !important;
          color: var(--gruvbox-fg) !important;
        }
        #urlbar[focused="true"],
        #urlbar[focused="true"] > #urlbar-background {
          background-color: var(--gruvbox-bg0_h) !important;
          box-shadow: 0 0 0 1px var(--gruvbox-blue) !important;
        }
        .urlbarView-row:hover,
        .urlbarView-row[selected] {
          background-color: var(--gruvbox-bg2) !important;
        }
        #urlbar-input,
        .urlbar-input {
          color: var(--gruvbox-fg1) !important;
        }

        /* 侧栏（历史/书签/扩展侧栏） */
        #sidebar-box,
        #zen-sidebar-splitter,
        #sidebar {
          background-color: var(--gruvbox-bg0) !important;
          color: var(--gruvbox-fg) !important;
        }
        #sidebar-header {
          background-color: var(--gruvbox-bg0) !important;
        }

        /* 弹出面板 / 菜单 */
        panel,
        menupopup {
          --arrowpanel-background: var(--gruvbox-bg1) !important;
          --arrowpanel-border-color: var(--gruvbox-bg2) !important;
          --arrowpanel-color: var(--gruvbox-fg) !important;
        }
        panelview,
        .panel-arrowcontent {
          background-color: var(--gruvbox-bg1) !important;
          color: var(--gruvbox-fg) !important;
        }
        menu,
        menuitem {
          color: var(--gruvbox-fg) !important;
        }
        menu[_moz-menuactive="true"],
        menuitem[_moz-menuactive="true"] {
          background-color: var(--gruvbox-bg2) !important;
        }

        /* 选中高亮 / 滚动条走系统 */
        #main-window {
          accent-color: var(--gruvbox-blue) !important;
        }
        #urlbar ::selection,
        #sidebar ::selection {
          background-color: var(--gruvbox-blue) !important;
          color: var(--gruvbox-bg0) !important;
        }

        /* 查找栏 / 下载等内建工具栏浮层跟随面板色 */
        #findbar,
        #downloadsPanel {
          background-color: var(--gruvbox-bg1) !important;
          color: var(--gruvbox-fg) !important;
        }
      '';

      # 内建页面（about:/chrome:/resource:）涂成 Gruvbox，滚动条全局统一
      # ⚠️ 普通网页不在此处强改（现代站点 CSS 复杂，易破坏）：
      #    - 支持暗色的站点：由 layout.css...content-override=1 报告 dark 自行适配
      #    - 其余站点：Dark Reader 兜底（默认安装即全站启用，颜色在其设置面板调整）
      # 注：Dark Reader 不实现 storage.managed（源码无 managed_schema），
      #     无法经 Nix policy 注入配色——故不要为其添加伪造的 3rdparty/ExtensionSettings 配置。
      userContent = ''
        /* ==========================================
           Gruvbox Dark - Zen internal pages
           ========================================== */

        @-moz-document
          url-prefix("about:"),
          url-prefix("chrome:"),
          url-prefix("resource:")
        {
          :root {
            color-scheme: dark !important;
            background-color: #282828 !important;
            color: #ebdbb2 !important;
          }

          body {
            background-color: #282828 !important;
            color: #ebdbb2 !important;
          }

          a {
            color: #83a598 !important;
          }

          a:visited {
            color: #d3869b !important;
          }

          ::selection {
            background-color: #504945 !important;
            color: #fbf1c7 !important;
          }
        }

        /* Scrollbars（含网页） */
        :root,
        * {
          scrollbar-color: #504945 #282828 !important;
        }
      '';
    };
  };
}
