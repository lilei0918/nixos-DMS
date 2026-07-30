{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./vesktop.nix
    ./theme-system24-noktis.nix
    ./theme-material-you-lavender.nix
  ];
}
