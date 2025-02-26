---
title: wsl环境初始化-安装nvm
date: 2023-08-27 23:48:19
toc: true
tags:
- wsl
- nvm
- nodejs
- linux
categories: ['技术博客']
---
# wsl环境初始化-安装nvm

## 安装 nodejs 环境

### 1.vscode版本：
```yml
版本: 1.82.0 (user setup)
提交: 8b617bd08fd9e3fc94d14adb8d358b56e3f72314
日期: 2023-09-06T22:07:07.438Z
Electron: 25.8.0
ElectronBuildId: 23503258
Chromium: 114.0.5735.289
Node.js: 18.15.0
V8: 11.4.183.29-electron.0
OS: Windows_NT x64 10.0.25941
```

### 2.修改host 
**有科学上网条件的就不用了，建议需要的上个机场**

`nslookup` 查看 github 的网站，修改 hosts
```bash
nslookup http://github.global.ssl.fastly.net
nslookup http://github.com
nslookup http://raw.githubusercontent.com

# hosts
199.16.158.9    http://github.global.ssl.fastly.net
199.16.158.9    https://github.global.ssl.fastly.net
20.205.243.166  http://github.com
20.205.243.166  https://github.com
185.199.111.133 http://raw.githubusercontent.com
185.199.111.133 https://raw.githubusercontent.com
185.199.110.133 http://raw.githubusercontent.com
185.199.110.133 https://raw.githubusercontent.com
185.199.108.133 http://raw.githubusercontent.com
185.199.108.133 https://raw.githubusercontent.com

```

*wsl 的 hosts 是复制宿主 windows的，所以要修改 windows hosts 就可以*

### 3.安装 nvm
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash

nvm install node # 安装最新版
```

