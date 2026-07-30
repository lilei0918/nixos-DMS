{
  config,
  pkgs,
  lib,
  ...
}:
{

  programs.vscodium = {
    enable = true;

    profiles.default.extensions = [
      pkgs.vscode-extensions.jnoortheen.nix-ide
      pkgs.vscode-extensions.bbenoist.nix
    ];
  };

  xdg.configFile."VSCodium/User/settings.json".text = ''
    {
      "nix.enableLanguageServer": true,
      "nix.serverPath": "nil",
      "nix.formatterPath": "alejandra",

      "editor.formatOnSave": true,

      "[nix]": {
        "editor.defaultFormatter": "jnoortheen.nix-ide",
        "editor.formatOnSave": true
      },

      "files.autoSave": "afterDelay",

      "editor.tabSize": 2,
      "editor.insertSpaces": true,

      "editor.fontFamily": "JetBrainsMono Nerd Font",
      "editor.fontSize": 14,

      "editor.minimap.enabled": false,

      "editor.renderWhitespace": "selection",

      "editor.smoothScrolling": true,

      "editor.cursorSmoothCaretAnimation": "on",

      "editor.stickyScroll.enabled": true,

      "editor.wordWrap": "on",

      "files.trimTrailingWhitespace": true,

      "files.insertFinalNewline": true,

      "files.exclude": {
        "**/.git": true,
        "**/.direnv": true,
        "**/result": true
      },

      "explorer.compactFolders": false,

      "workbench.list.smoothScrolling": true,

      "terminal.integrated.fontFamily": "JetBrainsMono Nerd Font",

      "terminal.integrated.fontSize": 14,

      "editor.bracketPairColorization.enabled": true
    }
  '';
}
