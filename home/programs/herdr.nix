{pkgs, ...}: {
  # ============================================================
  # herdr：coding agent 的终端工作区/多路复用器
  #
  # - 包来自 nixpkgs（随 nix flake update 周更）
  # - 配置由 Home-Manager 声明式托管（~/.config/herdr/config.toml）
  # - 改配置后执行：herdr server reload-config
  # ============================================================

  home.packages = [pkgs.herdr];

  xdg.configFile."herdr/config.toml".text = ''
    # herdr 配置（Home-Manager 托管，见 home/programs/herdr.nix）
    # 修改后：herdr server reload-config

    # 跳过首次引导（配置已声明式管理，避免程序回写）
    onboarding = false

    [theme]
    # 与整机 Gruvbox 统一；跟随终端亮/暗自动切换
    name = "gruvbox"
    auto_switch = true
    light_name = "gruvbox-light"
    dark_name = "gruvbox"

    [terminal]
    # 新交互 pane 使用 fish（与 niri 终端一致）
    default_shell = "fish"
    new_cwd = "follow"

    [keys]
    prefix = "ctrl+b"

    # 弹窗：lazygit（prefix+alt+g）
    [[keys.command]]
    key = "prefix+alt+g"
    type = "popup"
    command = "lazygit"
    width = "80%"
    height = "80%"
    description = "lazygit"

    # 弹窗：临时终端（prefix+t）
    [[keys.command]]
    key = "prefix+t"
    type = "popup"
    command = "exec \"''${SHELL:-fish}\""
    width = "80%"
    height = "80%"
    description = "scratch terminal"

    [ui]
    status_indicators = "symbols"
    tab_bar_position = "top"
    tab_bar_right = [
      { type = "hostname" },
      { type = "datetime", format = "%H:%M" },
    ]
    tab_bar_right_separator = " · "
    window_title = "{hostname}: {workspace}"

    [ui.toast]
    # system：交给桌面通知服务（DMS）弹通知
    delivery = "system"
    delay_seconds = 1

    [ui.sound]
    enabled = true

    [session]
    resume_agents_on_restore = true

    [worktrees]
    directory = "~/.herdr/worktrees"

    [advanced]
    # 每 pane 回滚缓冲 50MB（默认 10MB）
    scrollback_limit_bytes = 50000000
  '';
}
