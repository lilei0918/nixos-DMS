# Node.js 项目脚手架（pnpm + direnv）

## 使用

```bash
nix flake init -t ~/nixos-DMS#node
cd my-project                      # direnv 自动加载 devShell
pnpm install
pnpm add -D vite typescript eslint prettier   # 依赖装项目本地 node_modules
pnpm dev
```

## 说明

- node 版本由 Nix 提供（`nodejs_22`）；**不要 `npm install -g`**（rebuild 后失效）。
- 想固定 pnpm 版本：在 `package.json` 加 `"packageManager": "pnpm@9.x.x"`，配合 corepack 生效。
- 前端框架（react/vue 等）都走 `pnpm add` 项目内管理，互不干扰。
