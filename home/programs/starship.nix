{
  config,
  pkgs,
  ...
}: {
  programs.starship = {
    enable = true;

    settings = {
      # 不显示空白行
      add_newline = false;

      # Prompt 格式
      format = ''
        $username$hostname$directory$git_branch$git_status$nix_shell$character
      '';

      # 用户名
      username = {
        show_always = true;
        format = "[$user]($style) ";
        style_user = "bold cyan";
      };

      # 主机名
      hostname = {
        ssh_only = false;
        format = "[@$hostname](bold green) ";
      };

      # 当前目录
      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
        format = "[$path](bold blue) ";
      };

      # Git 分支
      git_branch = {
        symbol = " ";
        format = "[$symbol$branch](bold purple) ";
      };

      # Git 状态
      git_status = {
        disabled = false;
        format = "([$all_status$ahead_behind](bold red) )";
      };

      # Nix shell 环境提示
      nix_shell = {
        symbol = " ";
        format = "[$symbol$name](bold yellow) ";
      };

      # 最后的输入符号
      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };
    };
  };
}
