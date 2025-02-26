---
title : 'Github Sync 433 Error'
date : 2024-01-31T14:10:21+08:00
toc: true
tags: ['github','git']
categories: ['技术博客']
---
# Github Sync 433 Error

同步代码时报错,github,vscode 超时的错误

>fatal: unable to access 'https://github.com/livebug/myblog.git/': Failed to connect to github.com port 443 after 129947 ms: Couldn't connect to server

后来才发现 原来单独给系统配置了代理之后，debian中的git好像没有起作用；
需要单独给git中配置代理

```bash
git config --global http.proxy 127.0.0.1:7890
```
