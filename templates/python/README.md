# Python 项目脚手架（uv + direnv）

## 使用

```bash
# 1. 复制模板（在当前目录生成项目文件）
nix flake init -t ~/nixos-DMS#python
#    推送到 GitHub 后也可：nix flake init -t github:lilei0918/nixos-DMS#python

# 2. 进入项目（direnv 自动加载 devShell）
cd my-project        # 自动 use flake，进入 uv 环境

# 3. 用 uv 管理依赖（版本 / venv / lock 全自动）
uv add pandas
uv add requests
uv run python app.py # 或 uv run pytest
```

## 说明

- Python 版本、`.venv`、依赖、`uv.lock` 全部由 **uv** 管理，改依赖**不需要改 Nix**。
- 裸 `python3` 只作兜底；正式环境用 `uv run`。
- 系统级库（如编译 C 扩展、Qt 运行时）由 `gcc`/`pkg-config`/`nix-ld`（全局已配）提供，缺库时往 devShell 的 `packages` 或 `system/nix-ld.nix` 补。
- 想把工具（ruff/pytest/mypy）跟着项目走：`uv add --dev ruff pytest mypy`。
