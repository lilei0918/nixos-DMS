# Python + PySide6/QML 项目脚手架（uv + direnv）

适用于股票终端（Longbridge）、PySide6/QML、pyqtgraph 等项目。

## 使用

```bash
nix flake init -t ~/nixos-DMS#python-pyside6
cd my-project                      # direnv 自动加载 devShell
uv add akshare                     # 再加需要的包
uv run python main.py
```

## 说明

- PySide6 / pyqtgraph 已列入 `pyproject.toml`，`uv sync` 即可安装（wheel 自带 Qt，无需系统 Qt）。
- 运行时缺 `.so`（libGL/xcb 等）时：全局 `system/nix-ld.nix` 已提供大部分库；个别缺失往 devShell 的 `packages` 补。
- 若用 QML：QML 模块由 PySide6 wheel 提供，配合 niri/Wayland 直接跑。
