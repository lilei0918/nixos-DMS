# FHS 兼容环境
# 来源参照: ryan4yin/nix-config modules/nixos/desktop/fhs.nix
# 作用: 用 buildFHSEnv 造一个带标准 /usr 目录结构的运行环境,
#       让普通 Linux 二进制(AppImage/闭源软件/pip wheel)在 NixOS 上直接运行
{
  pkgs,
  myvars,
  ...
}: let
  # daA (~/Documents/daA) 的 PySide6/QtWebEngine/akshare 等 pip wheel
  # 所需的系统 C 库 —— 与 ~/Documents/daA/flake.nix 的 LD_LIBRARY_PATH 清单一致
  # 目的: 在 FHS 内免 LD_LIBRARY_PATH 拼接、免 patchelf 直接运行 daA
  daaLibs = with pkgs; [
    # Qt6 / PySide6 基础库
    libGL
    libGLU
    libx11
    libxrender
    libxcb
    libxext
    libxkbcommon
    libxcb-cursor
    libxcb-wm
    libxcb-util
    libxcb-image
    libxcb-keysyms
    libxcb-render-util
    libXcomposite
    libXdamage
    libXfixes
    libXrandr
    libXi
    libXtst
    fontconfig
    freetype
    dbus
    wayland

    # 通用运行库 (Python wheel 依赖)
    zlib
    bzip2
    xz
    openssl
    zstd
    glib
    gdk-pixbuf
    cairo
    pango
    harfbuzz
    icu
    expat

    # QtWebEngine / Chromium 专用
    nss
    nspr
    libsecret
    alsa-lib
    udev
    libevent
    at-spi2-core
    mesa
    libgbm
    libxshmfence
    libxkbfile
    libkrb5
    libSM
    libICE
    libtiff
    libjpeg
    libwebp
    libpng
    brotli
  ];
in {
  environment.systemPackages = [
    ############################################
    # 通用 fhs 命令: `fhs` 进入标准目录结构 shell,
    # 可直接运行 AppImage 解包产物 / 非 NixOS 二进制
    ############################################
    (let
      base = pkgs.appimageTools.defaultFhsEnvArgs;
    in
      pkgs.buildFHSEnv (base
        // {
          name = "fhs";
          targetPkgs = pkgs: (base.targetPkgs pkgs) ++ [pkgs.pkg-config];
          profile = "export FHS=1";
          runScript = "bash";
          extraOutputsToInstall = ["dev"];
        }))

    ############################################
    # daa-fhs 命令: 在 FHS 环境中启动 daA 股票看板
    # 替代 daA 项目内 LD_LIBRARY_PATH + patchelf 方案
    ############################################
    (let
      base = pkgs.appimageTools.defaultFhsEnvArgs;
      daaDir = "/home/${myvars.username}/Documents/daA";
      runScript = pkgs.writeShellScript "daa-fhs-run" ''
        export TDX_DATA_DIR="''${TDX_DATA_DIR:-/run/media/lilei/DATATB/TDXdata}"
        export TDX_MARK_PATH="$TDX_DATA_DIR/mark.dat"
        export MD_NOTES_PATH="''${MD_NOTES_PATH:-$HOME/Documents/OBbackup/04-自选股}"
        export BOARD_NOTES_PATH="''${BOARD_NOTES_PATH:-$HOME/Documents/OBbackup/05-板块研究}"
        mkdir -p "$TDX_DATA_DIR/blocknew" "$MD_NOTES_PATH" "$BOARD_NOTES_PATH"

        # QtWebEngine 在 NixOS 上无 setuid chrome-sandbox, 必须禁用沙箱
        export QTWEBENGINE_DISABLE_SANDBOX=1
        export QTWEBENGINE_CHROMIUM_FLAGS="--no-sandbox"
        export QT_QPA_PLATFORM="''${QT_QPA_PLATFORM:-wayland;xcb}"
        export QT_IM_MODULE=fcitx
        export XMODIFIERS="@im=fcitx"

        cd ${daaDir}
        exec .venv/bin/python main.py "$@"
      '';
    in
      pkgs.buildFHSEnv (base
        // {
          name = "daa-fhs";
          targetPkgs = pkgs:
            (base.targetPkgs pkgs) ++ daaLibs ++ [pkgs.pkg-config];
          runScript = "${runScript}";
        }))
  ];
}
