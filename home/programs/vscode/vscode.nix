{pkgs, ...}: {
  programs.vscodium = {
    enable = true;

    profiles.default = {
      # =========================
      # Extensions
      # =========================

      extensions = with pkgs.vscode-extensions; [
        # =========================
        # Nix
        # =========================

        jnoortheen.nix-ide

        # =========================
        # Git
        # =========================

        eamodio.gitlens

        # =========================
        # UI
        # =========================

        pkief.material-icon-theme

        # Catppuccin 主题（nixpkgs 自带）
        catppuccin.catppuccin-vsc

        # =========================
        # Markdown / Docs
        # =========================

        yzhang.markdown-all-in-one

        redhat.vscode-yaml

        # =========================
        # Spell Check
        # =========================

        streetsidesoftware.code-spell-checker
      ];

      # =========================
      # VSCodium Settings
      # =========================

      userSettings = {
        # -------------------------
        # Nix Language Server
        # -------------------------

        "nix.enableLanguageServer" = true;

        "nix.serverPath" = "nixd";

        # -------------------------
        # Nix Formatter
        # -------------------------

        # 启用 LSP 后 nix.formatterPath 无效（扩展文档说明），
        # 格式化由 nixd 处理，需经 nix.serverSettings 指定格式化器
        "nix.serverSettings" = {
          "nixd" = {
            "formatting" = {
              "command" = ["alejandra"];
            };
          };
        };

        "[nix]" = {
          "editor.defaultFormatter" = "jnoortheen.nix-ide";

          "editor.formatOnSave" = true;

          "editor.tabSize" = 2;

          "editor.insertSpaces" = true;
        };

        # -------------------------
        # General Editor
        # -------------------------

        "editor.formatOnSave" = true;

        "editor.minimap.enabled" = false;

        "editor.wordWrap" = "on";

        "files.autoSave" = "off";

        # -------------------------
        # Theme
        # -------------------------

        "workbench.colorTheme" = "Catppuccin Mocha";

        "workbench.iconTheme" = "material-icon-theme";

        # -------------------------
        # Terminal
        # -------------------------

        "terminal.integrated.fontFamily" = "JetBrainsMono Nerd Font";

        # 退出 Red Hat 扩展遥测
        "redhat.telemetry.enabled" = false;
      };
    };
  };

  # =========================
  # Nix Development Tools
  # =========================

  home.packages = with pkgs; [
    nixd

    alejandra
  ];
}
