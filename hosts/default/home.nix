{
  config,
  pkgs,
  lib,
  inputs,
  self,
  ...
}:
let
  allPackages = import ./packages.nix {
    inherit pkgs;
  };
in
{
  home.username = "lilei";
  home.homeDirectory = "/home/lilei";
  home.stateVersion = "24.11";

  imports = [
    # DMS
    inputs.dms.homeModules.dank-material-shell
    inputs.dms.homeModules.niri

    # niri
    inputs.niri.homeModules.niri

    # other modules
    ../../system/zsh.nix
    ../../home/programs/vscode.nix
    ../../home/programs/ghostty.nix
    ../../home/programs/firefox.nix
    ../../home/programs/cliphist.nix
    ../../home/programs/hermes.nix
    ../../home/programs/walker.nix
    ../../home/programs/thunar.nix
    ../../home/programs/theme.nix
    ../../home/programs/starship.nix
    ../../home/programs/dconf.nix
    ../../home/programs/fastfetch.nix
    #../../home/programs/xfsettingsd.nix
  ];

  ############################################
  # niri
  ############################################

  programs.niri = {
    enable = true;

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
  # cliphist
  ############################################

  services.cliphist = {
    enable = true;
    allowImages = true;
  };

  ############################################
  # environment
  ############################################

  home.sessionVariables = {
    EDITOR = "vim";

    # Wayland 下 fcitx5 环境
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  ############################################
  # home-manager
  ############################################

  programs.home-manager.enable = true;

}
