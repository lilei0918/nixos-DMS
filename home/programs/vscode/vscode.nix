{
  pkgs,
  ...
}: {

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

        zhuangtongfa.material-theme


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

        "nix.serverPath" = "nil";



        # -------------------------
        # Nix Formatter
        # -------------------------

        "nix.formatterPath" = "alejandra";



        "[nix]" = {

          "editor.defaultFormatter" =
            "jnoortheen.nix-ide";


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

        "workbench.colorTheme" =
          "One Dark Pro";


        "workbench.iconTheme" =
          "material-icon-theme";



        # -------------------------
        # Terminal
        # -------------------------

        "terminal.integrated.fontFamily" =
          "JetBrainsMono Nerd Font";


      };

    };

  };



  # =========================
  # Nix Development Tools
  # =========================

  home.packages = with pkgs; [

    nil

    alejandra

  ];

}