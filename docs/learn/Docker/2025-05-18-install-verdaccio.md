---
title: 使用 Docker 运行 Verdaccio 搭建私有 npm 仓库
tags:
  - Docker
  - Node.js
---

# 使用 Docker 运行 Verdaccio 搭建私有 npm 仓库

> Verdaccio 是一个轻量级的私有 npm 代理仓库，适合企业内部或离线环境下使用。

## 为什么需要私有 npm 仓库

| 场景 | 说明 |
|:---|:---|
| **离线环境** | 内网开发，无法访问公网 npm registry |
| **私有包管理** | 公司内部组件库不适宜发布到 npm 公网 |
| **代理加速** | 缓存公网包，减少重复下载 |
| **安全审计** | 控制可用的包版本，扫描漏洞 |

## 快速启动

### Docker 命令

```bash
docker run -d --name verdaccio \
  -p 4873:4873 \
  --restart=always \
  -v /your-path/verdaccio/conf:/verdaccio/conf \
  -v /your-path/verdaccio/storage:/verdaccio/storage \
  verdaccio/verdaccio
```

**参数说明：**

| 参数 | 含义 |
|:---|:---|
| `-d` | 后台运行容器 |
| `-p 4873:4873` | 端口映射（宿主机:容器） |
| `--restart=always` | 容器退出时自动重启 |
| `-v /conf` | 挂载配置文件目录 |
| `-v /storage` | 挂载包存储目录 |

### Docker Compose 方式 (推荐)

```yaml
# docker-compose.yml
version: '3.8'
services:
  verdaccio:
    image: verdaccio/verdaccio
    container_name: verdaccio
    ports:
      - "4873:4873"
    volumes:
      - ./verdaccio/conf:/verdaccio/conf
      - ./verdaccio/storage:/verdaccio/storage
    restart: always
```

```bash
docker compose up -d
```

## 客户端配置

### 设置 npm registry

```bash
# 设置为私有仓库
npm config set registry http://your-server:4873

# 或仅在当前项目使用
npm config set registry http://your-server:4873 --location project

# 查看当前 registry
npm config get registry
```

### pnpm 配置

```bash
pnpm config set registry http://your-server:4873
```

### 发布私有包

```bash
# 登录
npm login --registry http://your-server:4873

# 发布
npm publish --registry http://your-server:4873
```

## 常用配置

创建 `conf/config.yaml` 自定义 Verdaccio 行为：

```yaml
storage: /verdaccio/storage

# 上游代理（缓存 npm 公网包）
uplinks:
  npmjs:
    url: https://registry.npmjs.org/

# 包访问规则
packages:
  '@scope/*':
    access: $all
    publish: $authenticated
  '**':
    access: $all
    proxy: npmjs

# 监听配置
server:
  keepAliveTimeout: 60

# Web 管理界面
web:
  enable: true
  title: '私有 npm 仓库'
```

访问 `http://your-server:4873` 即可看到 Web 管理界面，支持搜索包、查看版本等操作。

## 离线环境注意事项

- 首次使用前需要联网同步所需的 npm 包
- 可以使用 `npm pack` 或 `pnpm pack` 手动导入离线包
- Verdaccio 存储目录可以直接迁移到离线服务器

