#!/bin/bash
# =============================================================================
# setup-debian-dev.sh — WSL2 Debian Trixie 一键开发环境初始化脚本
#
# 适用于: 全新安装的 WSL2 Debian GNU/Linux 13 (Trixie)
# 前提:   Windows 侧已运行 Clash (TUN 模式 + Allow LAN, 端口 7890)
#
# 用法:
#   chmod +x setup-debian-dev.sh
#   bash setup-debian-dev.sh
#
# 或远程执行:
#   bash <(curl -fsSL https://raw.githubusercontent.com/<repo>/<path>/setup-debian-dev.sh)
# =============================================================================

set -euo pipefail
IFS=$'\n\t'

# -------------------------------
# 颜色输出
# -------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

log_info()    { echo -e "${CYAN}[INFO]${NC}  $*"; }
log_done()    { echo -e "${GREEN}[OK]${NC}   $*"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error()   { echo -e "${RED}[ERR]${NC}  $*"; }

# -------------------------------
# 预检
# -------------------------------
preflight_check() {
    log_info "====== 预检 ======"

    # 检查是否 WSL
    if ! grep -qi "microsoft" /proc/version 2>/dev/null; then
        log_warn "未检测到 WSL 环境，脚本专为 WSL2 设计，继续执行可能有问题"
    fi

    # 检查 Debian
    if [ -f /etc/debian_version ]; then
        log_info "Debian $(cat /etc/debian_version)"
    else
        log_warn "非 Debian 系统，部分 apt 包名可能不兼容"
    fi

    # 获取 Windows 宿主机 IP（用于代理测试）
    WSL_HOST_IP=$(ip route show default 2>/dev/null | awk '{print $3}' || echo "")
    if [ -z "$WSL_HOST_IP" ]; then
        log_warn "无法获取 Windows 宿主机 IP，代理将不可用"
    else
        log_info "宿主机 IP: $WSL_HOST_IP"
        export http_proxy="http://$WSL_HOST_IP:7890"
        export https_proxy="http://$WSL_HOST_IP:7890"

        # 测试代理
        log_info "测试代理连通性..."
        if curl -sI --max-time 5 https://www.google.com > /dev/null 2>&1; then
            log_done "代理连通正常 ✓"
        else
            log_warn "代理连通失败，请检查 Clash 是否开启 Allow LAN 且端口为 7890"
        fi
    fi
}

# -------------------------------
# Section 1: 基础依赖
# -------------------------------
install_base() {
    log_info "====== [1/6] 安装基础依赖 ======"
    sudo apt update -y
    sudo apt install -y curl ca-certificates gnupg lsb-release
    log_done "基础依赖安装完成"
}

# -------------------------------
# Section 2: Node.js 22 LTS
# -------------------------------
install_nodejs() {
    log_info "====== [2/6] 安装 Node.js 22 LTS ======"

    if command -v node &> /dev/null; then
        log_info "已安装: $(node --version)，跳过"
        return
    fi

    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
    sudo apt install -y nodejs
    log_done "Node.js $(node --version) / npm $(npm --version)"
}

# -------------------------------
# Section 3: Java (OpenJDK 21 LTS)
# -------------------------------
install_java() {
    log_info "====== [3/6] 安装 Java (OpenJDK 21 LTS) ======"

    if command -v java &> /dev/null; then
        log_info "已安装: $(java -version 2>&1 | head -1)，跳过"
        return
    fi

    sudo apt update -y
    sudo apt install -y openjdk-21-jdk
    log_done "Java $(java -version 2>&1 | head -1)"
}

# -------------------------------
# Section 4: SSH Key 生成
# -------------------------------
setup_ssh() {
    log_info "====== [4/6] 配置 SSH Key ======"

    local SSH_KEY_FILE="$HOME/.ssh/id_ed25519"
    local GIT_EMAIL
    local GIT_NAME

    if [ -f "$SSH_KEY_FILE" ]; then
        log_info "SSH Key 已存在: $SSH_KEY_FILE，跳过生成"
    else
        # 交互式询问
        echo ""
        echo -e "${CYAN}请输入 Git 邮箱（用于 SSH 和 Git 配置）:${NC}"
        read -r -p "> " GIT_EMAIL
        echo -e "${CYAN}请输入 Git 用户名:${NC}"
        read -r -p "> " GIT_NAME

        mkdir -p ~/.ssh && chmod 700 ~/.ssh
        ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$SSH_KEY_FILE" -N ""
        log_done "SSH Key 已生成: $SSH_KEY_FILE"
        echo ""
        echo -e "${YELLOW}===== 公钥内容（复制到 GitHub → Settings → SSH Keys）=====${NC}"
        cat "${SSH_KEY_FILE}.pub"
        echo -e "${YELLOW}=========================================================${NC}"
        echo ""

        # Git 基础配置
        if [ -n "$GIT_NAME" ] && [ -n "$GIT_EMAIL" ]; then
            git config --global user.name "$GIT_NAME"
            git config --global user.email "$GIT_EMAIL"
            log_done "Git 全局用户已配置: $GIT_NAME <$GIT_EMAIL>"
        fi
    fi

    # 添加 GitHub host key
    if ! grep -q "github.com" ~/.ssh/known_hosts 2>/dev/null; then
        ssh-keyscan github.com >> ~/.ssh/known_hosts 2>/dev/null || true
        log_done "已添加 GitHub SSH host key"
    fi
}

# -------------------------------
# Section 5: 代理写入 ~/.bashrc
# -------------------------------
setup_proxy_bashrc() {
    log_info "====== [5/6] 配置代理到 ~/.bashrc ======"

    local PROXY_BLOCK

    # 检查是否已有代理配置
    if grep -q "# ========== WSL2 代理配置" "$HOME/.bashrc" 2>/dev/null; then
        log_info "~/.bashrc 中已有代理配置，跳过"
        return
    fi

    # 排除 Windows PATH（避免干扰）
    if ! grep -q "移除所有包含 /mnt/" "$HOME/.bashrc" 2>/dev/null; then
        cat >> "$HOME/.bashrc" <<'EOF'

# 移除所有包含 /mnt/ 的路径条目（禁用 Windows 程序干扰）
export PATH=$(echo "$PATH" | tr ':' '\n' | grep -v '/mnt/' | tr '\n' ':')
EOF
        log_info "已添加 Windows PATH 排除"
    fi

    # 代理配置
    cat >> "$HOME/.bashrc" <<'EOF'

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
EOF

    log_done "代理配置已写入 ~/.bashrc"
    log_info "请执行 'source ~/.bashrc' 使之生效"
}

# -------------------------------
# Section 6: 环境验证
# -------------------------------
verify_all() {
    log_info "====== [6/6] 验证安装结果 ======"

    echo ""
    echo -e "${GREEN}=== 环境验证结果 ===${NC}"
    echo ""

    local all_ok=true

    # Node.js
    if command -v node &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} Node.js:   $(node --version)"
    else
        echo -e "  ${RED}✗${NC} Node.js:   未安装"
        all_ok=false
    fi

    # npm
    if command -v npm &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} npm:       $(npm --version)"
    else
        echo -e "  ${RED}✗${NC} npm:       未安装"
        all_ok=false
    fi

    # Java
    if command -v java &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} Java:      $(java -version 2>&1 | head -1)"
    else
        echo -e "  ${RED}✗${NC} Java:      未安装"
        all_ok=false
    fi

    # Git
    if command -v git &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} Git:       $(git --version | awk '{print $3}')"
    else
        echo -e "  ${RED}✗${NC} Git:       未安装"
        all_ok=false
    fi

    # curl
    if command -v curl &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} curl:      $(curl --version | head -1 | awk '{print $2}')"
    else
        echo -e "  ${RED}✗${NC} curl:      未安装"
        all_ok=false
    fi

    # SSH Key
    if [ -f "$HOME/.ssh/id_ed25519" ]; then
        echo -e "  ${GREEN}✓${NC} SSH Key:   ~/.ssh/id_ed25519"
    else
        echo -e "  ${YELLOW}○${NC} SSH Key:   未生成（可选）"
    fi

    # 代理
    if [ -n "${http_proxy:-}" ]; then
        echo -e "  ${GREEN}✓${NC} Proxy:     $http_proxy"
    else
        echo -e "  ${YELLOW}○${NC} Proxy:     未设置（执行 source ~/.bashrc 后生效）"
    fi

    echo ""
    if [ "$all_ok" = true ]; then
        log_done "全部核心工具安装完成 ✓"
    else
        log_warn "部分工具未安装，请检查上方 ✗ 标记"
    fi
}

# -------------------------------
# 完成提示
# -------------------------------
print_final_notes() {
    echo ""
    echo -e "${GREEN}============================================${NC}"
    echo -e "${GREEN}  初始化完成！${NC}"
    echo -e "${GREEN}============================================${NC}"
    echo ""
    echo "【后续手动步骤】"
    echo ""
    echo "1. 使代理生效:"
    echo "   $ source ~/.bashrc"
    echo ""
    echo "2. 添加 SSH Key 到 GitHub:"
    echo "   - 打开 https://github.com/settings/keys"
    echo "   - 粘贴上面输出的公钥内容"
    echo "   - 测试: ssh -T git@github.com"
    echo ""
    echo "3. 安装 Docker Desktop (Windows 端):"
    echo "   - 下载: https://www.docker.com/products/docker-desktop/"
    echo "   - 安装时勾选 'Use WSL 2 instead of Hyper-V'"
    echo "   - Settings → Resources → WSL Integration → 启用当前 Debian"
    echo ""
    echo "4. 查看完整文档:"
    echo "   $ cat ~/docs/wsl2-debian-dev-setup.md"
    echo ""
}

# -------------------------------
# Main
# -------------------------------
main() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║   WSL2 Debian 开发环境一键初始化          ║${NC}"
    echo -e "${CYAN}║   Debian Trixie + Clash TUN (Windows)     ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
    echo ""

    preflight_check

    echo ""
    echo -e "${YELLOW}即将安装: 基础工具、Node.js、Java、SSH Key、代理配置${NC}"
    echo -e "${YELLOW}确认继续? [Y/n] ${NC}"
    read -r -p "> " confirm
    if [ "$confirm" = "n" ] || [ "$confirm" = "N" ]; then
        echo "已取消"
        exit 0
    fi

    install_base
    install_nodejs
    install_java
    setup_ssh
    setup_proxy_bashrc
    verify_all
    print_final_notes
}

main "$@"