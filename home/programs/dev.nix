{pkgs, ...}: {
  # 全局开发工具链：只放「工具」，项目依赖全部项目隔离（uv / pnpm 管理）。
  # 原则：不装全局 python 包 / node 包（会污染系统、rebuild 后失效、版本冲突）。
  #   Python → uv（版本 / .venv / 依赖 / lock 全由 uv 管）
  #   Node   → pnpm（依赖装项目本地 node_modules，不用 npm -g）
  # 项目脚手架模板见 templates/；工作流见 MEMO「十、开发环境」。
  home.packages = with pkgs; [
    # ─────────────────────────────
    # Python
    # ─────────────────────────────

    uv # Python 版本 + venv + 依赖 + lock

    python3 # 便利：裸 python3 跑小脚本 / 临时用（不装任何包）

    # ─────────────────────────────
    # Node
    # ─────────────────────────────

    nodejs_22 # Node LTS

    pnpm # 包管理器（corepack 已内置，按需启用）

    # ─────────────────────────────
    # 通用开发工具
    # ─────────────────────────────

    just # 任务运行器（可选）

    gh # GitHub CLI（PR / Issue / 搜索）

    yq # YAML 解析
  ];
}
