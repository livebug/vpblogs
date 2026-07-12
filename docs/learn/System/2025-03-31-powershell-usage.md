---
title: PowerShell 常用技巧与踩坑记录
tags:
  - Windows
---

# PowerShell 常用技巧与踩坑记录

> 从 CMD 迁移到 PowerShell 时遇到的各种问题和解决方案。

## 基础差异速查

| 操作 | CMD | PowerShell |
|:---|:---|:---|
| 换行符 | `^` | `` ` `` (反撇号) |
| 列出文件 | `dir` | `dir` 或 `Get-ChildItem` |
| 当前目录 | `cd` | `cd` 或 `Get-Location` |
| 环境变量 | `%PATH%` | `$env:PATH` |
| 清屏 | `cls` | `cls` 或 `Clear-Host` |
| 帮助 | `help cmd` | `Get-Help cmd` |

## 换行输入长命令

在 PowerShell 中，换行符是反撇号 `` ` ``（位于 Esc 键下方，不要和单引号混淆）：

```powershell
# 长命令换行
docker run -d `
  --name my-app `
  -p 8080:80 `
  -v $PWD/data:/data `
  my-image:latest
```

## 常用快捷键

| 快捷键 | 功能 |
|:---|:---|
| `Ctrl+R` | 搜索历史命令 |
| `Ctrl+Space` | 自动补全建议 |
| `F7` | 图形化历史记录 |
| `Tab` | 补全文件/命令 |
| `Ctrl+C` | 终止当前命令 |

## 执行脚本权限

PowerShell 默认禁止执行脚本，需要在**管理员模式**下修改执行策略：

```powershell
# 查看当前策略
Get-ExecutionPolicy

# 允许本地脚本执行
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

| 策略 | 含义 |
|:---|:---|
| Restricted | 默认，禁止所有脚本 |
| RemoteSigned | 本地脚本可执行，远程脚本需签名 |
| AllSigned | 所有脚本均需签名 |
| Unrestricted | 所有脚本均可执行（不推荐） |

## 常用命令

```powershell
# 查看端口占用
netstat -ano | findstr :8080

# 查找进程
Get-Process -Name node

# 终止进程
Stop-Process -Name node -Force

# 环境变量（持久化）
[Environment]::SetEnvironmentVariable("MY_VAR", "value", "User")

# 下载文件
Invoke-WebRequest -Uri "https://example.com/file.zip" -OutFile "file.zip"

# 文件哈希
Get-FileHash .\file.zip -Algorithm SHA256
```

## 个性化配置

PowerShell 配置文件路径：

```powershell
# 查看配置路径
$PROFILE

# 编辑配置
notepad $PROFILE
```

示例 `$PROFILE`：

```powershell
# 设置别名
Set-Alias which Get-Command
Set-Alias g git

# 美化提示符
function prompt {
    "PS [$env:USERNAME@$env:COMPUTERNAME $(Get-Location)]> "
}
```

