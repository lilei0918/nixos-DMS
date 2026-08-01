{
  pkgs,
  lib,
  ...
}: let
  rimeIceSrc = pkgs.fetchFromGitHub {
    owner = "iDvel";

    repo = "rime-ice";

    # 锁定到具体 commit，避免 main 分支浮动导致 hash 失配
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

  home.activation.rimeIceInstall = lib.hm.dag.entryAfter ["writeBoundary"] ''

    RIME_DIR="$HOME/.local/share/fcitx5/rime"


    mkdir -p "$RIME_DIR"


    if [ ! -f "$RIME_DIR/rime_ice.schema.yaml" ]; then

      cp -r ${rimeIceSrc}/* "$RIME_DIR/"

    fi

  '';

  home.packages = with pkgs; [
    librime

    librime-lua
  ];
}
