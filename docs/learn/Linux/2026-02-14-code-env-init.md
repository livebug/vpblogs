---
title: Linux 编程开发环境初始化
tags:
  - Linux
  - python
  - nodejs
  - nvm
---

#  Linux 编程开发环境初始化

## user 未出现在 sudoers 文件中。

将您的用户名添加到 sudo组（请将 your_username替换为您的实际用户名）：
```bash
nano /etc/sudoers
# 添加以下内容 到文件中
用户名 ALL=(ALL:ALL) ALL
```

在 Debian 13 中，`sudoers` 文件和 `group` 文件共同协作，构成了管理 `sudo` 权限的核心机制。它们的关系和分工非常明确。

### 1. 核心概念

*   **`/etc/group` （用户组文件）**
    *   **作用**：管理**用户和组的归属关系**。它定义了系统中有哪些组，以及哪些用户属于这些组。
    *   **关键条目**：`sudo:x:27:<用户名1>,<用户名2>,...`
    *   **含义**：这行仅表示列出的用户是 `sudo` 组的**成员**。它本身**不赋予任何 `sudo` 权限**，只定义了一种“分组”。

*   **`/etc/sudoers` （sudo 权限配置文件）**
    *   **作用**：定义**谁能以什么身份、执行什么命令**的详细规则。这是权限控制的**规则手册**。
    *   **关键条目**：`%sudo ALL=(ALL:ALL) ALL`
    *   **含义**：这行规则的意思是：**`sudo` 组的所有成员（`%sudo`），可以在所有主机上（第一个`ALL`），以任何用户和组的身份（`(ALL:ALL)`），运行所有命令（最后一个`ALL`）**。

### 2. 它们如何协同工作

这是标准的“**组-规则映射**”模式，也是 Debian 的默认推荐做法：

1.  **添加用户到组**：当你执行 `usermod -aG sudo <用户名>` 或直接编辑 `/etc/group` 时，你只是在“花名册”（group文件）上把用户的名字写进了 `sudo` 组。
2.  **规则生效**：`sudo` 命令在执行时，会去查阅“规则手册”（sudoers文件）。它发现有一条规则是 `%sudo ...`，于是它就去“花名册”（group文件）里查找所有属于 `sudo` 组的成员。
3.  **权限授予**：如果当前用户的名字在 `sudo` 组的成员列表里，那么 `sudo` 命令就根据 `%sudo` 那条规则，赋予其相应的超级用户权限。

**简单比喻**：
*   `/etc/group` 像是一个**部门的成员名单**（例如“运维部”）。
*   `/etc/sudoers` 像是一份**公司授权书**，上面写着：“授权‘运维部’的所有成员可以操作公司所有服务器”。
*   只有当你既在“运维部”名单里，公司又有对应的授权条款时，你才有权操作服务器。

### 3. 在 Debian 13 上的管理实践

| 操作目的 | 推荐命令/方法 | 说明 |
| :--- | :--- | :--- |
| **将用户加入 sudo 组** | `sudo usermod -aG sudo <用户名>` | **标准方法**。需要你已有另一个有 `sudo` 权限的账户。 |
| **直接编辑 sudoers（高级）** | `sudo visudo` | **唯一安全编辑此文件的方式**。它会进行语法检查，防止错误配置导致所有人无法使用 `sudo`。用于添加更复杂的规则。 |
| **检查用户的组** | `groups <用户名>` 或 `id <用户名>` | 查看用户当前属于哪些组。 |
| **修复“未在 sudoers 中”错误** | 通过 **恢复模式（单用户模式）** 获取 root 权限，然后修改 `/etc/group` 或使用 `usermod`。 | 这是当你没有任何 `sudo` 权限账户时的终极解决方法。 |

### 总结

在 Debian 13 中：
*   **`/etc/group`** 负责**记录关系**（谁在 `sudo` 组里）。
*   **`/etc/sudoers`** 负责**定义权限**（`sudo` 组的人有什么权力）。
*   默认情况下，**只需将用户添加到 `sudo` 组**，他们就能获得完整的 `sudo` 权限，因为 `sudoers` 文件已经为 `%sudo` 组预设了规则。

你之前通过恢复模式直接编辑 `/etc/group` 文件，将用户 `yuanbao` 添加到 `sudo` 组，正是利用了这套协同机制，是完全正确和有效的操作。

## python 安装

```bash
# 更新软件包列表
sudo apt update
sudo apt upgrade

# 安装 Python 3
sudo apt install -y python3 python3-pip python3-venv

# 创建名为 myenv 的虚拟环境
python3 -m venv myenv
 
# 激活虚拟环境
source myenv/bin/activate
```

### 安装 antlr4 库
```bash
pip install antlr4-python3-runtime 
```

## Java 安装

```bash
sudo apt install default-jdk
java -version
```

## Nvm 安装 nodejs

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
nvm install node
nvm install --lts
```
