{
  config,
  pkgs,
  lib,
  ...
}: {

  programs.vscodium = {

    enable = true;


    profiles.default.extensions =
      with pkgs.vscode-extensions; [

        # =========================
        # Nix
        # =========================

        jnoortheen.nix-ide


        # =========================
        # Git
        # =========================

        eamodio.gitlens


        # =========================
        # UI
        # =========================

        pkief.material-icon-theme

        zhuangtongfa.material-theme


        # =========================
        # Markdown / Docs
        # =========================

        yzhang.markdown-all-in-one

        redhat.vscode-yaml


        # =========================
        # Spell
        # =========================

        streetsidesoftware.code-spell-checker

      ];

  };


  # ===============================
  # Nix 开发工具
  # ===============================

  home.packages = with pkgs; [

    nil

    alejandra

  ];



  # ===============================
  # 初始化 VSCodium 配置
  #
  # 第一次生成真实文件
  # 后续由 VSCodium 自己管理
  # ===============================

  home.activation.vscodiumSettings =
    lib.hm.dag.entryAfter ["writeBoundary"] ''

      VSCODIUM_CONFIG="$HOME/.config/VSCodium/User"

      SETTINGS="$VSCODIUM_CONFIG/settings.json"


      if [ ! -e "$SETTINGS" ]; then

        mkdir -p "$VSCODIUM_CONFIG"


        cp ${./vscode-settings.json} \
          "$SETTINGS"


      fi

    '';

}
