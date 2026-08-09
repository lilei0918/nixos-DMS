{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  allPackages = import ./packages.nix {
    inherit pkgs;
  };
in {
  home.username = "lilei";
  home.homeDirectory = "/home/lilei";
  home.stateVersion = "25.05";

  imports = [
    # DMS
    inputs.dms.homeModules.dank-material-shell
    inputs.dms.homeModules.niri

    # niri
    inputs.niri.homeModules.niri

    # other modules
    ../../home/programs/rime.nix
    ../../home/programs/vscode/vscode.nix
    ../../home/programs/firefox.nix
    ../../home/programs/chrome.nix
    ../../home/programs/hermes.nix
    ../../home/programs/walker.nix
    ../../home/programs/thunar.nix
    ../../home/programs/theme.nix
    ../../home/programs/dconf.nix
    ../../home/programs/fastfetch.nix
    ../../home/programs/git.nix
    ../../home/programs/btop.nix
    ../../home/programs/AI/zed.nix
    ../../home/programs/AI/opencode.nix
    ../../home/programs/AI/pi.nix
    ../../home/terminal/alacritty.nix
    ../../home/terminal/fish.nix
    ../../home/terminal/starship.nix
    ../../home/terminal/tmux.nix
    ../../home/terminal/ghostty.nix
    ../../home/terminal/zsh.nix
  ];

  ############################################
  # niri
  ############################################

  programs.niri = {
    enable = true;

    # 系统 nixpkgs（f13ff45 起）的 pkgs.niri 引用了被删除的 libdisplay-info_0_2，
    # 故改用 niri-flake 自带的包（其 nixpkgs 已在 flake.nix 固定到 624af66）。
    # 上游修复后（niri-flake 改用 libdisplay-info 0.3）可移除本行。
    package = inputs.niri.packages.${pkgs.system}.niri-stable;

    settings = import ../../home/niri/default.nix {
      inherit
        config
        pkgs
        inputs
        lib
        ;
    };
  };

  ############################################
  # packages
  ############################################

  home.packages = lib.mkBefore allPackages;

  ############################################
  # fcitx5 + rime 用户配置
  ############################################

  home.file.".local/share/fcitx5/rime/default.custom.yaml".text = ''
    patch:
      schema_list:
        - schema: rime_ice

      menu:
        page_size: 9
  '';

  ############################################
  # fcitx5 默认输入法设置
  ############################################

  xdg.configFile."fcitx5/profile".text = ''
    [Groups/0]
    Name=Default
    Default Layout=us
    DefaultIM=rime

    [Groups/0/Items/0]
    Name=rime
    Layout=

    [Groups/0/Items/1]
    Name=keyboard-us
    Layout=

    [GroupOrder]
    0=Default
  '';

  ############################################
  # environment
  ############################################

  home.sessionVariables = {
    EDITOR = "vim";
  };

  # fcitx5 环境变量统一在 home/programs/rime.nix 中管理

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  ############################################
  # home-manager
  ############################################

  programs.home-manager.enable = true;
}
