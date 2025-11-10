#!/bin/bash
# Nushell 配置安装脚本 - 创建软链接到用户配置目录

set -e

# 颜色输出
info() { echo -e "\033[0;32m[INFO]\033[0m $1"; }
warn() { echo -e "\033[1;33m[WARN]\033[0m $1"; }
error() { echo -e "\033[0;31m[ERROR]\033[0m $1"; exit 1; }

# 检查 Nushell
command -v nu &>/dev/null || error "请先安装 Nushell"

# 目录配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nushell"

# 创建配置目录
mkdir -p "$CONFIG_DIR"

# 备份并创建软链接
link_file() {
    local src="$1" dst="$2"
    [ -e "$dst" ] && [ ! -L "$dst" ] && {
        local backup="${dst}.backup.$(date +%Y%m%d%H%M%S)"
        warn "备份: $dst -> $backup"
        mv "$dst" "$backup"
    }
    [ -L "$dst" ] && { warn "已存在: $dst"; return; }
    info "链接: $dst -> $src"
    ln -s "$src" "$dst"
}

# 创建软链接
link_file "$SCRIPT_DIR/config.nu" "$CONFIG_DIR/config.nu"
link_file "$SCRIPT_DIR/modules" "$CONFIG_DIR/modules"

# 初始化配置文件
[ ! -e "$CONFIG_DIR/env.nu" ] && {
    info "创建: $CONFIG_DIR/env.nu"
    cp "$SCRIPT_DIR/env.nu.example" "$CONFIG_DIR/env.nu"
}

[ ! -e "$CONFIG_DIR/wd_bookmarks.json" ] && {
    info "创建: wd_bookmarks.json"
    echo '{}' > "$CONFIG_DIR/wd_bookmarks.json"
}

info "安装完成！配置目录: $CONFIG_DIR"
warn "可编辑 $CONFIG_DIR/env.nu 添加本地环境变量"