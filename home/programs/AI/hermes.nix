{
  pkgs,
  inputs,
  ...
}: {
  # Hermes CLI + Hermes Desktop.
  # Uses the upstream flake output, which builds everything via uv2nix and
  # wraps Node/git/ripgrep/ffmpeg into the binary's PATH (no pip/venv/npm).
  # The `desktop` output provides the CLI (hermes/hermes-agent/hermes-acp).
  # NOTE: upstream `desktop` output does NOT ship a .desktop file, so we
  # declare one here to make Hermes Desktop appear in walker / app menus.
  #
  # 系统级 hermes-agent 网关服务（systemd + provider/model 设置）在
  # 同目录 hermes-service.nix（NixOS 模块，经 configuration.nix 导入）。
  home.packages = [inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.desktop];

  # Hermes Desktop 启动器（walker / 应用菜单可见）
  xdg.desktopEntries."hermes-desktop" = {
    name = "Hermes Desktop";
    genericName = "AI Assistant";
    comment = "Hermes AI assistant desktop app";
    exec = "hermes-desktop";
    icon = "utilities-terminal";
    terminal = false;
    type = "Application";
    categories = ["Utility" "Development"];
    startupNotify = false;
  };
}
