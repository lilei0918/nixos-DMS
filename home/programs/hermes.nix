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
