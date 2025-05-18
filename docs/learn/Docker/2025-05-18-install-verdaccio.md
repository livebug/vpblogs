---
title: 使用 Docker 运行 Verdaccio
tags:
  - Docker
  - Verdaccio
---

# 使用 Docker 运行 Verdaccio

初级命令：
```bash
docker run -it --name verdaccio -p 4873:4873 `
--restart=always `
-v C:/UserData/verdaccio/conf:/verdaccio/conf `
-v C:/UserData/verdaccio/storage:/verdaccio/storage `
verdaccio/verdaccio
```

+ 命令解释：
    + `-it` 参数表示以交互模式运行容器，并分配一个伪终端。
    + `--rm` 选项让容器在停止后自动删除
    + `-v` 增加本地存储
