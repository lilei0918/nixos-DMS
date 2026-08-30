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
  # 所需的系统 C 库 (daA 项目 flake 不再维护库清单, 统一在此维护)
  # 目的: 在 FHS 内免 LD_LIBRARY_PATH 拼接、免 patchelf 直接运行 daA
  daaLibs = with pkgs; [
    # C++ 标准库 (shiboken/numpy 等 C 扩展必需, 必须在最前)
    stdenv.cc.cc.lib

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

    # 以下补充自 system/nix-ld.nix 的库清单(富途 futu 实战验证),
    # 覆盖 GTK 渲染链、媒体栈与更多传递依赖:
    gtk3
    atk
    pcre2 # glib 依赖
    libffi # glib 依赖
    graphite2 # harfbuzz 依赖
    cups # Chromium 打印支持
    libdrm
    libepoxy # GL 派发
    libpulseaudio
    libxcursor
    lz4
    libbsd
    libmd # libbsd 依赖
    libcap
    libgcrypt
    libgpg-error
    librsvg
    curl
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
    # 用法: daa-fhs [脚本名], 默认 main.py
    ############################################
    (let
      base = pkgs.appimageTools.defaultFhsEnvArgs;
      daaDir = "/home/${myvars.username}/Documents/daA";
      runScript = pkgs.writeShellScript "daa-fhs-run" ''
        # 用法: daa-fhs [脚本名] [参数...]
        #   默认 main.py (主界面); 也支持 news_main.py 等
        _script="''${1:-main.py}"
        shift 2>/dev/null || true

        # libstdc++ 等部分库落在 /usr/lib64, 而 glibc 默认只搜 /lib 与 /usr/lib,
        # 必须显式补全搜索路径; 另需追加 PySide6 自带 Qt 库目录
        # (QtWebEngineProcess 无 rpath, 靠它找 libQt6WebEngineCore)
        # python 版本动态探测, 避免 venv 升级后路径失效
        _pyside_qt_lib="$(ls -d ${daaDir}/.venv/lib/python3.*/site-packages/PySide6/Qt/lib 2>/dev/null | head -1)"
        export LD_LIBRARY_PATH="/usr/lib64:/usr/lib''${_pyside_qt_lib:+:''${_pyside_qt_lib}}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

        export TDX_DATA_DIR="''${TDX_DATA_DIR:-/run/media/${myvars.username}/DATATB/TDXdata}"
        # 备注(长/短)以 win11 通达信(zd_zybGA) 显示的 T0002/mark.dat 为准
        export TDX_MARK_PATH="''${TDX_MARK_PATH:-/run/media/${myvars.username}/DATATB/Program Files/zd_zybGA/T0002/mark.dat}"
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
        exec .venv/bin/python "$_script" "$@"
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
