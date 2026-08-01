{...}: {
  programs.starship = {
    enable = true;

    settings = {
      # =============================
      # General
      # =============================

      add_newline = false;

      format = ''
        $username$hostname$directory$git_branch$git_status$cmd_duration$character
      '';

      # =============================
      # User
      # =============================

      username = {
        show_always = true;

        style_user = "bold green";
      };

      # =============================
      # Host
      # =============================

      hostname = {
        ssh_only = false;

        style = "bold yellow";
      };

      # =============================
      # Directory
      # =============================

      directory = {
        style = "bold cyan";

        truncation_length = 3;

        truncate_to_repo = false;
      };

      # =============================
      # Git
      # =============================

      git_branch = {
        symbol = " ";

        style = "bold purple";
      };

      git_status = {
        style = "yellow";
      };

      # =============================
      # Command duration
      # =============================

      cmd_duration = {
        min_time = 1000;

        format = "[$duration](yellow) ";
      };

      # =============================
      # Prompt symbol
      # =============================

      character = {
        success_symbol = "[❯](bold green)";

        error_symbol = "[❯](bold red)";
      };

      # =============================
      # Nix shell
      # =============================

      nix_shell = {
        symbol = " ";

        format = "[$symbol$state]($style) ";
      };
    };
  };
}
