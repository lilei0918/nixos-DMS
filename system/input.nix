{
  pkgs,
  lib,
  config,
  ...
}: let
  rimeIceSrc = pkgs.fetchFromGitHub {
    owner = "iDvel";
    repo = "rime-ice";
    rev = "main";
    hash = "sha256-kqn3c5qAotPmItFQURrGtWIko4vQPNqH7S3d1t4nwwU=";
  };

  # 雾凇拼音数据
  rimeIceData = pkgs.stdenv.mkDerivation {
    pname = "rime-ice-data";
    version = "git-main";

    src = rimeIceSrc;

    installPhase = ''
      mkdir -p $out/share/rime-data
      cp -r . $out/share/rime-data/
    '';
  };
in {
  ############################################
  # fcitx5 + rime
  ############################################

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";

    fcitx5 = {
      waylandFrontend = true;

      addons = with pkgs; [
        fcitx5-rime
        fcitx5-gtk
        fcitx5-material-color
        qt6Packages.fcitx5-chinese-addons
        qt6Packages.fcitx5-configtool
      ];
    };
  };

  ############################################
  # 系统安装
  ############################################

  environment.systemPackages = with pkgs; [
    librime
    librime-lua

    rimeIceData
  ];
}
