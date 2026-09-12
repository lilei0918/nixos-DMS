{
  pkgs,
  lib,
  inputs,
  myvars,
  ...
}: let
  allPackages = import ./packages.nix {
    inherit pkgs;
  };
in {
  ############################################
  # 1. 模块导入
  ############################################

  imports = [
    # -- DMS / niri --
    inputs.dms.homeModules.dank-material-shell

    # niri 手写 KDL 配置（系统层 programs.niri 见 system/niri.nix）
    ../../home/niri/kdl.nix

    # -- 桌面应用 --
    ../../home/programs/theme.nix
    ../../home/programs/dconf.nix
    ../../home/programs/walker.nix
    ../../home/programs/thunar.nix
    ../../home/programs/fastfetch.nix
    ../../home/programs/appimages.nix

    # -- 浏览器 --
    ../../home/programs/chrome.nix
    ../../home/programs/zen.nix
    # ../../home/programs/firefox.nix

    # -- 开发工具 --
    ../../home/programs/AI/vscode.nix
    ../../home/programs/AI/zed.nix
    ../../home/programs/AI/opencode.nix
    ../../home/programs/AI/codex.nix
    ../../home/programs/AI/pi.nix
    ../../home/programs/git.nix
    ../../home/programs/dev.nix
    ../../home/programs/herdr.nix

    # -- 输入法 / 常用工具 --
    ../../home/programs/rime.nix
    ../../home/programs/btop.nix
    # 暂停使用游戏工具包（保留文件，需要时取消注释重新导入）
    # ../../home/programs/gaming.nix

    # -- 终端 / Shell --
    ../../home/terminal/alacritty.nix
    ../../home/terminal/fish.nix
    ../../home/terminal/starship.nix
    ../../home/terminal/tmux.nix
    ../../home/terminal/ghostty.nix
    ../../home/terminal/zsh.nix
  ];

  ############################################
  # 2. home：身份 / 状态 / 包 / 环境 / 文件
  ############################################

  home = {
    inherit (myvars) username homeDirectory;

    stateVersion = "25.05";

    # ---------- 用户级软件包 ----------
    # mkBefore：用户级包在 PATH 中优先于模块自动安装的包
    packages = lib.mkBefore allPackages;

    # ---------- 会话环境变量 ----------
    sessionVariables = {
      EDITOR = "vim";
    };
    # fcitx5 环境变量统一在 home/programs/rime.nix 中管理

    # ---------- 声明式文件 ----------

    # Clash Verge Rev 的 geodata（替换为标准库）
    # 默认 geosite.dat 是 v2fly/domain-list-community 系，没有 gfw 分类，
    # clash 配置里 nameserver-policy 引用 geosite:gfw 会报
    # "list gfw not found in geosite.dat"。
    # 这里用 Loyalsoldier 增强版规则库（v2ray-rules-dat，含 gfw/google 等）
    # 覆盖 Clash Verge Rev 数据目录（~/.local/share/io.github.clash-verge-rev...）里的文件。
    # ⚠️ 若在 GUI 里更新过 geo 数据（覆盖掉 symlink），需重跑 switch 恢复。
    file = {
      "clash-verge-geosite.dat" = {
        target = ".local/share/io.github.clash-verge-rev.clash-verge-rev/geosite.dat";

        source = "${pkgs.v2ray-rules-dat}/share/v2ray/geosite.dat";

        force = true;
      };

      "clash-verge-geoip.dat" = {
        target = ".local/share/io.github.clash-verge-rev.clash-verge-rev/geoip.dat";

        source = "${pkgs.v2ray-rules-dat}/share/v2ray/geoip.dat";

        force = true;
      };
    };
  };

  ############################################
  # 3. programs：direnv / home-manager
  ############################################

  programs = {
    direnv = {
      enable = true;

      nix-direnv.enable = true;
    };

    "home-manager".enable = true;
  };

  ############################################
  # 4. xdg 配置（fcitx5）
  ############################################
  # rime 目录与 default.custom.yaml 统一在 home/programs/rime.nix 中声明。
  #
  # ⚠️ 曾尝试"分程序输入法状态"（fcitx5-input-state 按 app_id 强制中/英文），
  #    实测不可靠（依赖 niri event-stream 的 WindowOpenedOrChanged 事件，但当前 niri
  #    只发 WindowFocusChanged；且 -o/-c 只切换激活状态、不切 rime/keyboard-us），
  #    已整体移除：所有程序默认英文输入（fcitx5 inactive），需要中文时手动切 rime。
  #
  # fcitx5 由 niri spawn-at-startup（home/niri/conf/spawn-at-startup.kdl）显式 spawn，
  # 用 Hidden=true 覆盖 fcitx5 包自带的 XDG autostart 条目，
  # 否则 systemd-xdg-autostart-generator 会二次拉起 fcitx5，
  # 争抢 D-Bus 名导致 "Is there another fcitx already running?"。

  xdg.configFile = {
    "autostart/org.fcitx.Fcitx5.desktop".text = ''
      [Desktop Entry]
      Hidden=true
    '';

    "fcitx5/profile".text = ''
      [Groups/0]
      Name=Default
      Default Layout=us
      DefaultIM=keyboard-us

      [Groups/0/Items/0]
      Name=rime
      Layout=

      [Groups/0/Items/1]
      Name=keyboard-us
      Layout=

      [GroupOrder]
      0=Default
    '';
  };
}
