---
title: vitepress 部署发布到 github pages
tags:
  - VitePress
---

# vitepress 部署，发布到gitpages

将 vitepress 项目发布到某一个分支，github pages 配置展示，并增加上自动化流程。

## 配置 actions

这份工作流定义了自动化构建并部署 VitePress 站点到 GitHub Pages 的过程。每当向 `master` 分支推送代码时，GitHub Actions 会：
1. 签出最新的代码。
2. 设置 Node.js 环境并安装依赖。
3. 构建站点并将构建产物上传到 GitHub Pages。

```yml
# 构建 VitePress 站点并将其部署到 GitHub Pages 的示例工作流程
#
name: Deploy VitePress site to Pages

on:
  # 在针对 `main` 分支的推送上运行。如果你
  # 使用 `master` 分支作为默认分支，请将其更改为 `master`
  push:
    branches: [master]

  # 允许你从 Actions 选项卡手动运行此工作流程
  workflow_dispatch:

# 设置 GITHUB_TOKEN 的权限，以允许部署到 GitHub Pages
permissions:
  contents: read
  pages: write
  id-token: write

# 只允许同时进行一次部署，跳过正在运行和最新队列之间的运行队列
# 但是，不要取消正在进行的运行，因为我们希望允许这些生产部署完成
concurrency:
  group: pages
  cancel-in-progress: false

jobs:
  # 构建工作
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0 # 如果未启用 lastUpdated，则不需要
      # - uses: pnpm/action-setup@v3 # 如果使用 pnpm，请取消此区域注释
      #   with:
      #     version: 9
      # - uses: oven-sh/setup-bun@v1 # 如果使用 Bun，请取消注释
      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: 24
          # cache: pnpm # 或 pnpm / yarn
      - name: Instal PNPM
        run: npm i -g pnpm
      - name: Setup Pages
        uses: actions/configure-pages@v4
      - name: Install dependencies
        run: pnpm install # 或 pnpm install / yarn install / bun install
      - name: Build with VitePress
        run: pnpm docs:build # 或 pnpm docs:build / yarn docs:build / bun run docs:build
      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: docs/.vitepress/dist

  # 部署工作
  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    needs: build
    runs-on: ubuntu-latest
    name: Deploy
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

## `upload-pages-artifact` 这一步的具体作用：

在 GitHub Actions 中，`actions/upload-pages-artifact` 用于将构建生成的文件（或其他工件）上传到 GitHub 的存储空间，以便稍后的步骤使用（在本例中是用于部署到 GitHub Pages）。你提到的这一步，实际上是在构建阶段完成的，上传的是构建产物，即存放在 `docs/.vitepress/dist` 目录中的文件。


```yaml
- name: Upload artifact
  uses: actions/upload-pages-artifact@v3
  with:
    path: docs/.vitepress/dist
```

- **`uses: actions/upload-pages-artifact@v3`**: 使用 `upload-pages-artifact` 动作的版本 3，上传指定的文件。
- **`with: path: docs/.vitepress/dist`**: 这里指定了要上传的文件路径，即 VitePress 构建后生成的文件夹 `docs/.vitepress/dist`。这些是最终用于部署到 GitHub Pages 的文件。

### 具体流程：
1. **构建阶段**：当你执行 `pnpm docs:build` 时，VitePress 会把构建的文件输出到 `docs/.vitepress/dist` 目录。这个目录中包含了所有构建后的静态文件，如 HTML 文件、CSS 文件和 JavaScript 文件。
   
2. **上传产物**：`actions/upload-pages-artifact` 会将 `docs/.vitepress/dist` 目录中的所有内容打包并上传为一个“工件”。这个工件实际上是暂时存储在 GitHub Actions 的环境中，供后续的部署步骤使用。

3. **部署阶段**：接下来的部署步骤会使用 `actions/deploy-pages` 将这些文件部署到 GitHub Pages，确保站点可以通过 GitHub Pages URL 访问。

### 工作流中的这一部分的作用是：

- **存储和传输构建文件**：`upload-pages-artifact` 动作负责将构建的文件从当前的 GitHub Actions 工作流中传输到部署阶段。在这里它暂存到 GitHub Actions 的存储区域，供后续的 `deploy` 步骤使用。
  
- **解耦构建和部署**：通过使用工件上传，构建和部署可以在不同的步骤中进行。这种做法有助于避免因构建问题而导致部署失败，或者便于重新部署已经构建的内容。

### 小结：
`actions/upload-pages-artifact` 是一种将构建文件从工作流的一部分传递到另一部分的机制，它允许你在 GitHub Actions 的不同步骤之间共享数据。在这个工作流中，它用于将构建的 VitePress 站点文件上传，为之后的 GitHub Pages 部署做准备。

默认情况下，上传的工件会保留 90天，这意味着从上传时间开始，GitHub 会保留这些工件并允许你在此期间下载或查看。

在 90 天后，GitHub 会自动清理这些工件。如果你需要保留这些文件更长时间，可以手动下载它们或使用其他存储方式（例如存储在其他外部服务上）。