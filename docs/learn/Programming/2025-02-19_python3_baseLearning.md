---
title: Python3 基础——pip 与虚拟环境
tags:
  - Programming
  - Python
---

# Python3 基础——pip 与虚拟环境

> Python 项目管理的三件套：pip、venv 和 requirements.txt。

## 一、虚拟环境 venv

虚拟环境用于隔离不同项目的依赖，避免版本冲突。

### 创建与激活

```bash
# 创建虚拟环境
python3 -m venv .venv

# 激活 (Linux/macOS)
source .venv/bin/activate

# 激活 (Windows PowerShell)
.venv\Scripts\Activate.ps1

# 激活 (Windows CMD)
.venv\Scripts\activate.bat

# 退出

deactivate
```

### VSCode 配置

项目根目录创建 `.vscode/settings.json`：

```json
{
  "python.defaultInterpreterPath": "${workspaceFolder}/.venv/bin/python"
}
```

VSCode 会自动检测并提示切换到虚拟环境。

## 二、依赖管理

### 生成 requirements.txt

```bash
# 导出当前环境的包
pip freeze > requirements.txt
```

`requirements.txt` 示例：

```
flask==3.0.0
requests==2.31.0
sqlalchemy==2.0.25
```

### 离线下载依赖

在内网或离线环境下，可以先在有网的机器上下载包，再传输到离线环境安装：

```bash
# 根据 requirements.txt 下载包到本地目录
pip download -r requirements.txt -d ./packages/

# 离线安装（在目标机器上）
pip install --no-index --find-links=./packages/ -r requirements.txt
```

### 安装与卸载

```bash
# 从 requirements.txt 安装
pip install -r requirements.txt

# 安装最新版本
pip install requests

# 安装指定版本
pip install requests==2.31.0

# 卸载
pip uninstall requests

# 列出已安装的包
pip list
```

## 三、常用 pip 命令速查

| 命令 | 作用 |
|:---|:---|
| `pip install <pkg>` | 安装包 |
| `pip install -U <pkg>` | 升级包 |
| `pip uninstall <pkg>` | 卸载包 |
| `pip list` | 列出已安装的包 |
| `pip show <pkg>` | 查看包详情 |
| `pip freeze > requirements.txt` | 导出依赖 |
| `pip config list` | 查看 pip 配置 |
| `pip cache purge` | 清除缓存 |

## 四、配置国内镜像源

```bash
# 临时使用
pip install -i https://pypi.tuna.tsinghua.edu.cn/simple flask

# 永久配置
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
```

常用国内源：

| 源 | URL |
|:---|:---|
| 清华 | `https://pypi.tuna.tsinghua.edu.cn/simple` |
| 阿里云 | `https://mirrors.aliyun.com/pypi/simple` |
| 中科大 | `https://pypi.mirrors.ustc.edu.cn/simple` |

