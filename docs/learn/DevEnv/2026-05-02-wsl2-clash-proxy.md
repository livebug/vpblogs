---
title: WSL2 + Clash TUN 模式代理配置
tags:
  - WSL2
  - Clash
  - Proxy
  - Network
  - DevEnv
---

# WSL2 + Clash TUN 模式代理配置

## 背景

Clash 在 Windows 上以 TUN 虚拟网卡模式运行，拦截系统流量。但 WSL2 使用独立的 Hyper-V NAT 网络，TUN 的流量拦截**不会自动覆盖 WSL2 内部流量**，需要额外配置代理环境变量。

## 环境信息

| 项目 | 值 |
|------|-----|
| WSL 版本 | WSL2 (Linux 6.6.87.2-microsoft-standard-WSL2) |
| 宿主机 IP | `172.17.96.1`（vEthernet WSL 适配器） |
| Clash 代理端口 | `7890`（HTTP/HTTPS/SOCKS5 混合端口） |
| 宿主 IP 获取方式 | `ip route show default \| awk '{print $3}'` |

> **注意**：`/etc/resolv.conf` 中的 nameserver (`10.255.255.254`) 是 WSL2 DNS 中继，不可用于代理连接。

## 配置内容

已添加到 `~/.bashrc` 末尾：

```bash
# ========== WSL2 代理配置 (Clash LAN) ==========
# 通过默认网关获取 Windows 宿主机 IP
wsl_host_ip=$(ip route show default 2>/dev/null | awk '{print $3}')
if [ -n "$wsl_host_ip" ]; then
    export http_proxy="http://$wsl_host_ip:7890"
    export https_proxy="http://$wsl_host_ip:7890"
    export all_proxy="socks5://$wsl_host_ip:7890"
    # 跳过代理的地址（本地、局域网、VPN 私有网段）
    export no_proxy="localhost,127.0.0.1,::1,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"
fi
unset wsl_host_ip
```

### 生效方式

- **新终端**：自动加载
- **当前终端**：执行 `source ~/.bashrc`

### 验证

```bash
source ~/.bashrc
echo $http_proxy
# 输出: http://172.17.96.1:7890
```

## 前置要求

Clash 必须开启 **Allow LAN（允许局域网连接）**，使 WSL2 能通过宿主机 IP 访问代理端口。

## WSL1 vs WSL2 区别

| 场景 | 需要额外配置 |
|------|-------------|
| WSL1 + TUN | ❌ 不需要，WSL1 直接复用 Windows 网络栈 |
| WSL2 + TUN (NAT) | ✅ 需要配置 `http_proxy` 环境变量 |
| WSL2 + mirrored 网络模式 (Win11 22H2+) | ❌ 不需要，镜像网络栈 |

## 相关文件

- `~/.bashrc` — 代理环境变量配置