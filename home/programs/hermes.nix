{
  pkgs,
  inputs,
  ...
}: {
  # Hermes CLI + Hermes Desktop.
  # Uses the upstream flake output, which builds everything via uv2nix and
  # wraps Node/git/ripgrep/ffmpeg into the binary's PATH (no pip/venv/npm).
  # The `desktop` output provides both the CLI (hermes/hermes-agent/hermes-acp)
  # and the .desktop launcher, reusing the existing ~/.hermes/ state.
  home.packages = [inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.desktop];
}
