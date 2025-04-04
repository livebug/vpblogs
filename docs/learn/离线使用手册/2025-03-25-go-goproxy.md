---
title: Golang 离线使用
tags:
  - Golang
  - go
---
# Golang 离线使用
>离线环境中搭建 `Golang` 的开发环境，前提是有一个能联网的设备，因为需要下载一些东西。基本处理流程，安装语言开发包，准备离线私有仓库，准备开发工具插件。

## 一、下载语言开发包
1. 下载开发包，离线安装，首选免安装版本
[All releases - The Go Programming Language](https://golang.google.cn/dl/)

![Pasted image 20250325130039.png](../../public/images/Pasted%20image%2020250325130039.png)

2. 上传离线环境，配置环境变量
`Path`、`GOPATH`、`GOROOT`

- `GOROOT`：`GOROOT` 就是Go的安装目录，（类似于java的JDK）
- `GOPATH`：`GOPATH` 是我们的工作空间,保存go项目代码和第三方依赖包
 
<details><summary>需要提前下载安装包并解压好，添加环境变量需要管理员权限。</summary> 

  ```powershell
  # 根据输入的目录，将go的压缩包解压到指定目录
  # 该脚本需要在管理员权限下运行
  param (
      [string]$goPath = "C:\Soft\Go" # 默认安装路径
  )

  # 设置 powershell 编码utf8

  Write-Output "开始安装Go语言..."
  Write-Output "安装路径: $goPath"

  # 检查目录是否存在
  if (Test-Path $goPath) {
      Write-Output "目录 $goPath 已存在，是否覆盖？(Y/N)"
      $inputs = Read-Host
      if ($inputs -ne "Y" -and $inputs -ne "y") {
          Write-Output "安装取消"
          exit
      }
  } else {
      New-Item -ItemType Directory -Path $goPath -Force | Out-Null
  }

  # 获取当前目录
  $currentDir = Get-Location
  # Write-Output "当前目录: $currentDir"

  # 将当前目录下的go目录复制到指定目录 
  $version = "go1.24.1.windows-amd64"
  $sourcePath = "$currentDir\$version\go\*"
  $destinationPath = "$goPath\$version"
  # 清理目标目录
  if (Test-Path $destinationPath) {
      Write-Output "清理目标目录 $destinationPath"
      Remove-Item -Path "$destinationPath\*" -Recurse -Force
  }

  Write-Output "复制go文件夹到 $destinationPath"
  Copy-Item -Path $sourcePath -Destination $destinationPath -Recurse -Force

  if ($?) {
      Write-Output "复制成功"
  } else {
      Write-Output "复制失败"
      exit
  }

  # 设置环境变量
  $envPath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
  $goRootEnv = "$destinationPath"
  $goBinPath = "$goRootEnv\bin"
  $goPathEnv = "F:\03UserData\go"

  [System.Environment]::SetEnvironmentVariable("GOPATH", $goPathEnv, "Machine")
  [System.Environment]::SetEnvironmentVariable("GOROOT", $goRootEnv, "Machine")
  [System.Environment]::SetEnvironmentVariable("GO111MODULE", "on", "Machine")
  [System.Environment]::SetEnvironmentVariable("Path", "$envPath;$goBinPath:$goPathEnv\bin", "Machine")

  # 打印环境变量
  $envPath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
  $goPathEnv = [System.Environment]::GetEnvironmentVariable("GOPATH", "Machine")
  $goRootPath = [System.Environment]::GetEnvironmentVariable("GOROOT", "Machine") 

  Write-Output "环境变量设置成功"
  Write-Output "GOPATH: $goPathEnv"   
  Write-Output "GOROOT: $goRootPath"
  Write-Output "Path: $envPath"
  Write-Output "Go语言安装完成"
  ```
  
</details>

## 二、准备离线私有库

使用 [goproxy/goproxy: A minimalist Go module proxy handler.](https://github.com/goproxy/goproxy) 搭建私有服务。

<details><summary>方法一、使用自建项目代码搭建</summary>

- 要以编程方式使用此项目， 请获取它：
```shell
go get github.com/goproxy/goproxy
```

创建一个名为 `goproxy.go` 的文件:

```go
package main

import (
	"net/http"

	"github.com/goproxy/goproxy"
)

func main() {
	http.ListenAndServe("localhost:8080", &goproxy.Goproxy{})
}
```

然后使用与 go env GOMODCACHE 不同的 GOMODCACHE 运行它：

```bash
GOMODCACHE=/tmp/goproxy-gomodcache go run goproxy.go
```

最后，设置 GOPROXY 进行试用：

```bash
go env -w GOPROXY=http://localhost:8080,direct
```
</details>

<details><summary>方法二、使用命令运行</summary>


- 要从命令行使用此项目，请从源代码构建它： 

```shell
go install github.com/goproxy/goproxy/cmd/goproxy@latest
```

其他的跟自建代码类似

```bash
GOMODCACHE=/tmp/goproxy-gomodcache goproxy server --address localhost:8080
 
go env -w GOPROXY=http://localhost:8080,direct
 
goproxy --help # For more details
```

</details>

## 三、相关知识
### 1. `go.mod`、`go.sum`
- **`go.mod`**：管理Go项目的模块和依赖，定义项目的模块名称和依赖关系。
- **`go.sum`**：记录依赖模块的校验和信息，确保依赖的一致性和完整性。
### 2. go项目初始化吗，会自动生成 go.mod、go.sum
```bash
go mod init <project_name>
```
### 3. 使用 `go mod` 操作
- **初始化模块**：`go mod init example.com/myproject`
- **添加依赖项**：`go get github.com/gin-gonic/gin@v1.6.3`
- **更新依赖项**：`go get -u`
- **清理依赖项**：`go mod tidy`
- **验证依赖项**：`go mod verify`
- **下载依赖项到 vendor 目录**：```go mod vendor```

 