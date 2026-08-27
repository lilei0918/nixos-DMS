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

      # 系统 nixpkgs（f13ff45 起）的 pkgs.niri 引用了被删除的 libdisplay-info_0_2，
      # 故改用 niri-flake 自带的包（其 nixpkgs 已在 flake.nix 固定到 624af66）。
      # 上游修复后（niri-flake 改用 libdisplay-info 0.3）可移除本行。
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

  # fcitx5 行为配置：按窗口记忆中/英输入状态
  # ShareInputState=No = 每个窗口各自记住自己的中/英状态（不再全局共享手动切换）
  # force=true：磁盘已有 fcitx5 运行时写入的真实文件，且之后 configtool 改动也会覆盖符号链接
  xdg.configFile."fcitx5/config" = {
    force = true;

    text = ''
      [Hotkey]
      # Enumerate when holding modifier of Toggle key
      EnumerateWithTriggerKeys=True
      # Enumerate Input Method Forward
      EnumerateForwardKeys=
      # Enumerate Input Method Backward
      EnumerateBackwardKeys=
      # Skip first input method while enumerating
      EnumerateSkipFirst=False
      # Time limit in milliseconds for triggering modifier key shortcuts
      ModifierOnlyKeyTimeout=250

      [Hotkey/TriggerKeys]
      0=Control+space
      1=Zenkaku_Hankaku
      2=Hangul

      [Hotkey/ActivateKeys]
      0=Hangul_Hanja

      [Hotkey/DeactivateKeys]
      0=Hangul_Romaja

      [Hotkey/AltTriggerKeys]
      0=Shift_L

      [Hotkey/EnumerateGroupForwardKeys]
      0=Super+space

      [Hotkey/EnumerateGroupBackwardKeys]
      0=Shift+Super+space

      [Hotkey/PrevPage]
      0=Up

      [Hotkey/NextPage]
      0=Down

      [Hotkey/PrevCandidate]
      0=Shift+Tab

      [Hotkey/NextCandidate]
      0=Tab

      [Hotkey/TogglePreedit]
      0=Control+Alt+P

      [Behavior]
      # Activate input method by default
      ActiveByDefault=False
      # Reset state on Focus In
      resetStateWhenFocusIn=No
      # Share Input State
      ShareInputState=No
      # Show preedit in application
      PreeditEnabledByDefault=True
      # Show Input Method Information when switch input method
      ShowInputMethodInformation=True
      # Show Input Method Information when changing focus
      showInputMethodInformationWhenFocusIn=False
      # Show compact input method information
      CompactInputMethodInformation=True
      # Show first input method information
      ShowFirstInputMethodInformation=True
      # Default Candidates per page
      DefaultPageSize=5
      # Override XKB Option
      OverrideXkbOption=False
      # Custom XKB Option
      CustomXkbOption=
      # Force Enabled Addons
      EnabledAddons=
      # Force Disabled Addons
      DisabledAddons=
      # Preload input method to be used by default
      PreloadInputMethod=True
      # Allow input method in the password field
      AllowInputMethodForPassword=False
      # Show preedit text when typing password
      ShowPreeditForPassword=False
      # Interval of saving user data in minutes
      AutoSavePeriod=30
    '';
  };
}
