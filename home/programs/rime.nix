# ⚠️ RIME 部署提醒（重要，勿忘）
#
# rebuild / 重启后，若输入法未出现雾凇方案，需要手动触发一次 rime 部署：
#
#   fcitx5-remote -r
#
# 原因：home.file 以声明式方式管理 rime 目录，rebuild 会重新同步文件；
# fcitx5-rime 对新文件的部署是懒触发的，需要 reload 才会重新生成 build/ 产物。
# （-r = reload fcitx config；不要用 -rc，-c 是 inactivate 语义）
#
# 若 -r 后 5-10 秒仍无雾凇，检查：
#   ls ~/.local/share/fcitx5/rime/rime_ice.schema.yaml   # 应存在
#   ls ~/.local/share/fcitx5/rime/symbols_v.yaml         # 应存在（缺失会导致 resource could not be loaded）
{pkgs, ...}: let
  rimeIceSrc = pkgs.fetchFromGitHub {
    owner = "iDvel";
    repo = "rime-ice";

    rev = "8a3d9470c00add3cc93da20aac0c6d4a1ab37895";

    hash = "sha256-+C/4Z44+hguaGgA8SShNLs1wKbgVYOFTLkJqGFiOqb8=";
  };
in {
  home.sessionVariables = {
    GTK_IM_MODULE = "fcitx";

    QT_IM_MODULE = "fcitx";

    XMODIFIERS = "@im=fcitx";

    SDL_IM_MODULE = "fcitx";
  };

  # rime-ice 配置
  home.file.".local/share/fcitx5/rime" = {
    source = rimeIceSrc;

    recursive = true;
  };

  home.packages = with pkgs; [
    librime

    librime-lua
  ];
}
