{
  config,
  pkgs,
  lib,
  inputs,
  myvars,
  ...
}: let
  allPackages = import ./packages.nix {
    inherit pkgs lib;
  };
in {
  home = {
    inherit (myvars) username homeDirectory;

    stateVersion = "25.05";

    ############################################
    # packages
    ############################################

    # mkBefore：用户级包在 PATH 中优先于模块自动安装的包
    packages = lib.mkBefore allPackages;

    ############################################
    # environment
    ############################################

    sessionVariables = {
      EDITOR = "vim";
    };

    # fcitx5 环境变量统一在 home/programs/rime.nix 中管理
  };

  imports = [
    # DMS
    inputs.dms.homeModules.dank-material-shell
    inputs.dms.homeModules.niri

    # niri
    inputs.niri.homeModules.niri

    # other modules
    ../../home/programs/rime.nix
    ../../home/programs/vscode/vscode.nix
    # ../../home/programs/firefox.nix
    ../../home/programs/chrome.nix
    ../../home/programs/dev.nix
    ../../home/programs/walker.nix
    ../../home/programs/thunar.nix
    ../../home/programs/theme.nix
    ../../home/programs/dconf.nix
    ../../home/programs/fastfetch.nix
    ../../home/programs/git.nix
    ../../home/programs/btop.nix
    # 暂停使用游戏工具包（保留文件，需要时取消注释重新导入）
    # ../../home/programs/gaming.nix
    ../../home/programs/AI/zed.nix
    ../../home/programs/AI/opencode.nix
    ../../home/programs/AI/pi.nix
    ../../home/programs/AI/hermes.nix
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

  programs = {
    niri = {
      enable = true;

      # 说明（2026-08 核实）：nixpkgs 侧已修复——锁定 nixpkgs 的 pkgs.niri（26.04）
      # 用 libdisplay-info 0.4.0 正常构建，libdisplay-info_0_2 已删除；
      # 但 niri-flake 仍未修复（其 master flake.nix 仍 assert libdisplay-info_0_2 == "0.2.0"），
      # 故继续用 niri-flake 自带的 niri-stable（v25.08，其 nixpkgs pin 在 flake.nix 的 624af66）。
      # 待 niri-flake 改用 libdisplay-info 0.3+ 后可移除本行（并改用 pkgs.niri）。
      package = inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri-stable;

      settings = import ../../home/niri/default.nix {
        inherit
          config
          pkgs
          inputs
          lib
          myvars
          ;
      };
    };

    ############################################
    # direnv
    ############################################

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    ############################################
    # home-manager
    ############################################

    "home-manager".enable = true;
  };

  ############################################
  # fcitx5 默认输入法设置
  # （rime 目录与 default.custom.yaml 统一在 home/programs/rime.nix 中声明）
  #
  # ⚠️ 曾尝试"分程序输入法状态"（fcitx5-input-state 按 app_id 强制中/英文），
  # 实测不可靠（依赖 niri event-stream 的 WindowOpenedOrChanged 事件，但当前 niri
  # 只发 WindowFocusChanged；且 -o/-c 只切换激活状态、不切 rime/keyboard-us），
  # 已整体移除：所有程序默认英文输入（fcitx5 inactive），需要中文时手动切 rime。
  ############################################

  # fcitx5 由 niri autostart（home/niri/autostart.nix）显式 spawn，
  # 用 Hidden=true 覆盖 fcitx5 包自带的 XDG autostart 条目，
  # 否则 systemd-xdg-autostart-generator 会二次拉起 fcitx5，
  # 争抢 D-Bus 名导致 "Is there another fcitx already running?"。
  xdg.configFile."autostart/org.fcitx.Fcitx5.desktop".text = ''
    [Desktop Entry]
    Hidden=true
  '';

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
}
