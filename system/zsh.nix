{
  pkgs,
  config,
  lib,
  ...
}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autocd = true;
    autosuggestion.enable = true;

    dirHashes = {
      dl = "$HOME/Downloads";
      docs = "$HOME/Documents";
      dev = "$HOME/Dev";
      dots = "$HOME/Dev/nixland";
      pics = "$HOME/Pictures";
      vids = "$HOME/Videos";
    };

    history = {
      expireDuplicatesFirst = true;
      ignoreDups = true;
      ignoreSpace = true;
      path = "${config.xdg.dataHome}/zsh_history";
    };

    syntaxHighlighting = {
      enable = true;
      highlighters = ["main" "brackets" "pattern" "cursor" "regexp" "root" "line"];
    };

    oh-my-zsh = {
      enable = true;
      theme = "ys"; # Starship 会接管提示符
      plugins = ["git" "sudo"];
    };

    shellAliases = {
      cleanup = "sudo nix-collect-garbage --delete-older-than 1d";
      listgen = "sudo nix-env -p /nix/var/nix/profiles/system --list-generations";
      nixremove = "nix-store --gc";
      test-build = "sudo nixos-rebuild test --flake .#default";
      switch-build = "sudo nixos-rebuild switch --flake .#default";
      g = "git";
      gs = "git status";
      ga = "git add -A";
      add = "git add .";
      commit = "git commit -m";
      gc = "git commit -m";
      push = "git push";
      pull = "git pull";
      c = "clear";
      o = "onedrive-sync-all";
    };

    initContent = ''
      eval "$(starship init zsh)"
    '';
  };

  programs.starship.enable = true;
}
