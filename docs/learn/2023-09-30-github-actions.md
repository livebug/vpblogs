---
title : '使用 Github Actions 自动化发布博客' 
date : 2023-09-30T13:58:58+08:00
toc: true
tags: ["github actions","hugo","github"]

---

# 使用 Github Actions 自动化发布博客

介绍背景：

博客网站`myblog`仓库底下有两个子库，一个子库是用来存储`markdown`文章的`blogs`仓库，一个是用来存储`public`内容的`github pages`库 `livebug.github.io`仓库

当博客网站样式更新提交，或者文章提交，触发`myblog`仓库的 actions ，执行完之后发布到pages仓库


## 开发`myblog`仓库的提交 actions

```yml
# Sample workflow for building and deploying a Hugo site to GitHub Pages
name: Deploy Hugo site to Pages

on:
  # Runs on pushes targeting the default branch
  push:
    branches: ["master"]

  # Allows you to run this workflow manually from the Actions tab
  workflow_dispatch:

# Sets permissions of the GITHUB_TOKEN to allow deployment to GitHub Pages
permissions:
  contents: read
  pages: write
  id-token: write

# Allow only one concurrent deployment, skipping runs queued between the run in-progress and latest queued.
# However, do NOT cancel in-progress runs as we want to allow these production deployments to complete.
concurrency:
  group: "pages"
  cancel-in-progress: false

# Default to bash
defaults:
  run:
    shell: bash

jobs:
  # Build job
  public:
    runs-on: ubuntu-latest
    env:
      HUGO_VERSION: 0.114.0
    steps:
      - name: Setup Hugo # 初始化 护工环境
        uses: peaceiris/actions-hugo@v2
        with:
          hugo-version: "latest" 
      - name: Checkout # 检出资源
        uses: actions/checkout@v3
        with:
          submodules: recursive # 子模块，当前是 blogs 仓库
      - name: Build with Hugo   # 编译生成
        env:
          # For maximum backward compatibility with Hugo modules
          HUGO_ENVIRONMENT: production
          HUGO_ENV: production
        run: |
          hugo  
      - name: Deploy  # 发布
        uses: peaceiris/actions-gh-pages@v3
        with:
          personal_token: ${{ secrets.PERSONAL_TOKEN }} # 另外还支持 deploy_token 和 github_token
          external_repository: livebug/livebug.github.io # 修改为你的 GitHub Pages 仓库
          publish_dir: ./public
          publish_branch: master
```

## 子库提交，父库刷新触发action，并重新部署

1. 基础道理，提交到`blogs`中，触发仓库中的`action`，重新提交父库

2. 提交父库时，会触发父库的`action`，自动重新部署

```yml
name: Send submodule updates to parent repo

on:
  push:
    branches: 
      - master

jobs:
  update:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v2  # 检出父库
        with: 
          repository: livebug/myblog
          token: ${{ secrets.PERSONAL_TOKEN }}
          submodules: true

      - name: Pull & update submodules recursively # 更新子库
        run: |
          git submodule update --init --recursive
          git submodule update --recursive --remote

      - name: Commit      # 父库提交
        run: |
          git config user.email "actions@github.com"
          git config user.name "GitHub Actions - update submodules"
          git add --all
          git commit -m "Update submodules" || echo "No changes to commit"
          git push
```


## action 认证失败
需要重新刷新一下密钥，因为生成密钥时选择了期限，重新在仓库变量那重新输入刷新一下