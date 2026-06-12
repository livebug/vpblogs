#!/bin/bash
# =============================================================================
# setup-project-env.sh — vpblogs 博客项目环境初始化脚本
#
# 功能:
#   1. 检测 Node.js 是否安装
#   2. 安装/启用 pnpm (版本与 package.json 中 packageManager 字段一致)
#   3. 安装项目依赖 (pnpm install)
#   4. 生成 Git 时间线数据
#   5. 运行开发服务器验证
#
# 用法:
#   chmod +x scripts/setup-project-env.sh
#   bash scripts/setup-project-env.sh
#
# 前提: 需要已安装 Node.js (>= 22 LTS)
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
# 获取项目根目录
# -------------------------------
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
log_info "项目根目录: $PROJECT_ROOT"

# -------------------------------
# Section 1: 预检 Node.js
# -------------------------------
check_nodejs() {
    log_info "====== [1/5] 检测 Node.js ======"

    if ! command -v node &> /dev/null; then
        log_error "未检测到 Node.js，请先运行系统初始化脚本: scripts/setup-debian-dev.sh"
        log_error "或手动安装 Node.js 22 LTS 后再执行本脚本"
        exit 1
    fi

    local NODE_VERSION
    NODE_VERSION=$(node --version)
    log_done "Node.js: $NODE_VERSION"

    # 检查版本 >= 18 (VitePress 最低要求)
    local MAJOR_VER
    MAJOR_VER=$(echo "$NODE_VERSION" | sed 's/v//' | cut -d. -f1)
    if [ "$MAJOR_VER" -lt 18 ]; then
        log_warn "Node.js 版本过低 ($NODE_VERSION)，VitePress 需要 >= 18，建议升级到 22 LTS"
        echo -n "是否继续？[y/N]: "
        read -r REPLY
        if [ "$REPLY" != "y" ] && [ "$REPLY" != "Y" ]; then
            exit 1
        fi
    fi
}

# -------------------------------
# Section 2: 安装 pnpm
# -------------------------------
install_pnpm() {
    log_info "====== [2/5] 安装 pnpm ======"

    # 从 package.json 读取期望的 pnpm 版本
    local EXPECTED_VERSION
    EXPECTED_VERSION=$(node -e "
        const fs = require('fs');
        const pkg = JSON.parse(fs.readFileSync('$PROJECT_ROOT/package.json', 'utf-8'));
        if (pkg.packageManager && pkg.packageManager.startsWith('pnpm@')) {
            const v = pkg.packageManager.split('@')[1].split('+')[0];
            process.stdout.write(v);
        } else {
            process.stdout.write('latest');
        }
    ")
    log_info "期望 pnpm 版本: $EXPECTED_VERSION"

    # 检查 corepack 是否可用
    if command -v corepack &> /dev/null; then
        log_info "使用 corepack 管理 pnpm..."
        corepack enable
        # corepack 会根据 package.json 的 packageManager 字段自动准备对应版本
        corepack prepare "pnpm@${EXPECTED_VERSION}" --activate 2>/dev/null || true
        if command -v pnpm &> /dev/null; then
            log_done "pnpm $(pnpm --version) (via corepack)"
            return
        fi
    fi

    # 如果 pnpm 已全局安装
    if command -v pnpm &> /dev/null; then
        log_info "pnpm 已安装: $(pnpm --version)"
        return
    fi

    # 通过 npm 全局安装
    log_info "通过 npm 安装 pnpm@$EXPECTED_VERSION..."
    npm install -g "pnpm@${EXPECTED_VERSION}"
    log_done "pnpm $(pnpm --version)"
}

# -------------------------------
# Section 3: 安装项目依赖
# -------------------------------
install_deps() {
    log_info "====== [3/5] 安装项目依赖 ======"

    cd "$PROJECT_ROOT"

    if [ -d "node_modules" ]; then
        log_info "已存在 node_modules，是否重新安装？[y/N]: "
        read -r REPLY
        if [ "$REPLY" = "y" ] || [ "$REPLY" = "Y" ]; then
            log_info "清理旧依赖..."
            rm -rf node_modules
            pnpm install
        else
            log_info "跳过依赖安装"
            return
        fi
    else
        pnpm install
    fi

    log_done "项目依赖安装完成"
}

# -------------------------------
# Section 4: 生成 Git 时间线数据
# -------------------------------
generate_git_data() {
    log_info "====== [4/5] 生成 Git 时间线数据 ======"

    cd "$PROJECT_ROOT"

    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_warn "当前目录不是 Git 仓库，跳过 Git 时间线数据生成"
        return
    fi

    node scripts/git-log-to-json.js
    log_done "Git 时间线数据已生成 (public/data/git-log.json)"
}

# -------------------------------
# Section 5: 验证 & 启动开发服务器
# -------------------------------
verify_and_start() {
    log_info "====== [5/5] 验证 & 启动 ======"

    cd "$PROJECT_ROOT"

    # 验证关键依赖
    echo ""
    echo -e "${GREEN}=== 项目环境验证 ===${NC}"
    echo ""

    local all_ok=true

    echo -e "  ${GREEN}✓${NC} Node.js:   $(node --version)"
    echo -e "  ${GREEN}✓${NC} pnpm:      $(pnpm --version)"

    # 检查 vitepress 是否已安装 (直接读 package.json 拿版本，避免启动进程卡住)
    local vp_pkg="$PROJECT_ROOT/node_modules/vitepress/package.json"
    if [ -f "$vp_pkg" ]; then
        local vp_ver
        vp_ver=$(node -e "try{process.stdout.write(require('$vp_pkg').version)}catch(e){process.stdout.write('unknown')}" 2>/dev/null)
        echo -e "  ${GREEN}✓${NC} VitePress:  v$vp_ver"
    else
        echo -e "  ${RED}✗${NC} VitePress:  未安装"
        all_ok=false
    fi

    # 检查其他关键依赖
    for dep in "vitepress-markdown-timeline" "vitepress-sidebar" "vue" "fs-extra"; do
        if [ -d "node_modules/$dep" ]; then
            echo -e "  ${GREEN}✓${NC} $dep"
        else
            echo -e "  ${RED}✗${NC} $dep"
            all_ok=false
        fi
    done

    # 检查 Git 时间线数据
    if [ -f "public/data/git-log.json" ]; then
        echo -e "  ${GREEN}✓${NC} git-log.json (时间线数据)"
    else
        echo -e "  ${YELLOW}○${NC} git-log.json: 未生成 (非 Git 仓库或需手动执行)"
    fi

    echo ""

    if [ "$all_ok" = false ]; then
        log_error "部分依赖缺失，请检查上方 ✗ 标记并重新执行 pnpm install"
        exit 1
    fi

    log_done "项目环境初始化完成 ✓"
    echo ""
    echo -e "${GREEN}============================================${NC}"
    echo -e "${GREEN}  VitePress 博客项目就绪！${NC}"
    echo -e "${GREEN}============================================${NC}"
    echo ""
    echo "【可用命令】"
    echo ""
    echo "  启动开发服务器:"
    echo "    $ pnpm run docs:dev"
    echo ""
    echo "  构建静态站点:"
    echo "    $ pnpm run docs:build"
    echo ""
    echo "  预览构建结果:"
    echo "    $ pnpm run docs:preview"
    echo ""

    # 询问是否立即启动开发服务器
    echo -n -e "${CYAN}是否立即启动开发服务器？[y/N]: ${NC}"
    read -r REPLY
    if [ "$REPLY" = "y" ] || [ "$REPLY" = "Y" ]; then
        log_info "启动开发服务器 (Ctrl+C 停止)..."
        pnpm run docs:dev
    fi
}

# -------------------------------
# Main
# -------------------------------
main() {
    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║     vpblogs — VitePress 博客项目初始化       ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════╝${NC}"
    echo ""

    check_nodejs
    install_pnpm
    install_deps
    generate_git_data
    verify_and_start
}

main "$@"
