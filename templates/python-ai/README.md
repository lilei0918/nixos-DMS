# Python AI/Data 项目脚手架（uv + direnv）

适用于数据分析、LLM、AI 音频、脑科学等。

## 使用

```bash
nix flake init -t ~/nixos-DMS#python-ai
cd my-project                      # direnv 自动加载 devShell
uv add numpy pandas polars         # 按需加依赖（torch/transformers 等）
uv add --dev ruff pytest           # 开发工具跟着项目走
uv run jupyter lab
```

## 说明

- 数据栈（numpy/pandas/polars）、notebook（jupyter/ipykernel）、lint（ruff/pytest）建议全部用 `uv` 项目内管理，**不要全局装**。
- 需要 GPU（torch+cuda）时：先 `nix search nixpkgs cuda` 或加对应 CUDA 运行时库到 devShell，再 `uv add torch --index ...`（具体按官方 wheel 指引）。
