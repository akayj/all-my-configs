#!/usr/bin/env bash
# Homebrew 中国镜像源配置工具

set -e

# 镜像源配置 (名称|Git镜像|Bottle镜像)
readonly MIRRORS=(
    "清华|https://mirrors.tuna.tsinghua.edu.cn/git/homebrew|https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
    "中科大|https://mirrors.ustc.edu.cn|https://mirrors.ustc.edu.cn/homebrew-bottles"
    "阿里云|https://mirrors.aliyun.com/homebrew|https://mirrors.aliyun.com/homebrew/homebrew-bottles"
    "腾讯云|https://mirrors.cloud.tencent.com/homebrew|https://mirrors.cloud.tencent.com/homebrew-bottles"
    "官方|https://github.com/Homebrew|"
)

# 解析镜像配置
parse_mirror() {
    local name="$1" field="$2"
    for item in "${MIRRORS[@]}"; do
        [[ "${item%%|*}" == "$name" ]] || continue
        echo "$item" | cut -d'|' -f"$field"
        return 0
    done
    return 1
}

# 配置 Git 仓库镜像
setup_git_repos() {
    local base_url="$1"
    local repo_path

    # 配置主仓库
    git -C "$(brew --repo)" remote set-url origin "$base_url/brew.git"

    # 配置 homebrew-core（如果存在）
    repo_path="$(brew --repo homebrew/core 2> /dev/null)" || true
    if [[ -d "$repo_path" ]]; then
        git -C "$repo_path" remote set-url origin "$base_url/homebrew-core.git"
    fi

    # 配置 homebrew-cask（如果存在）
    repo_path="$(brew --repo homebrew/cask 2> /dev/null)" || true
    if [[ -d "$repo_path" ]]; then
        git -C "$repo_path" remote set-url origin "$base_url/homebrew-cask.git"
    fi
}

# 配置 Bottle 镜像
setup_bottle() {
    local bottle_url="$1"
    local rc_file="${ZDOTDIR:-$HOME}/.zshrc"
    [[ -n "$BASH_VERSION" ]] && rc_file="$HOME/.bash_profile"

    # 清理旧配置
    [[ -f "$rc_file" ]] && sed -i.bak '/HOMEBREW_BOTTLE_DOMAIN/d' "$rc_file"

    # 设置新配置
    if [[ -n "$bottle_url" ]]; then
        echo "export HOMEBREW_BOTTLE_DOMAIN=$bottle_url" >> "$rc_file"
        export HOMEBREW_BOTTLE_DOMAIN="$bottle_url"
    fi
}

# 应用镜像配置
apply_mirror() {
    local name="$1"
    local git_url bottle_url

    git_url=$(parse_mirror "$name" 2) || {
        echo "错误: 未知镜像 '$name'"
        return 1
    }
    bottle_url=$(parse_mirror "$name" 3)

    echo "==> 配置镜像: $name"
    setup_git_repos "$git_url"
    setup_bottle "$bottle_url"

    printf "==> Updating Homebrew..."
    if brew update > /dev/null 2>&1; then
        printf "\r\033[32m==> Updated Homebrew \033[0m\n"
    else
        printf "\r\033[31m错误: Homebrew 更新失败\033[0m\n"
        return 1
    fi

    local current_git_repo=$(git -C "$(brew --repo)" remote get-url origin)
    printf "==> 当前 Git 仓库地址: %s\n" "$current_git_repo"
}

# 交互式选择
select_mirror() {
    local names=() choice
    for item in "${MIRRORS[@]}"; do
        names+=("${item%%|*}")
    done

    if command -v fzf > /dev/null 2>&1; then
        choice=$(printf '%s\n' "${names[@]}" \
                                             | fzf --prompt='镜像源> ' \
                --height=40% --layout=reverse --border \
                --header='使用 ↑↓ 选择，Enter 确认')
    else
        PS3="选择镜像源: "
        select choice in "${names[@]}"; do
            [[ -n "$choice" ]] && break
        done
    fi

    # 显示选中镜像的详细信息
    if [[ -n "$choice" ]]; then
        echo "" >&2
        echo "已选择: $choice" >&2
        for m in "${MIRRORS[@]}"; do
            if [[ "${m%%|*}" == "$choice" ]]; then
                echo "Git:    $(echo "$m" | cut -d'|' -f2)" >&2
                b=$(echo "$m" | cut -d'|' -f3)
                [[ -n "$b" ]] && echo "Bottle: $b" >&2 || echo "Bottle: (官方源)" >&2
                break
            fi
        done
        echo "" >&2
    fi

    echo "$choice"
}

# 主函数
cn_brew() {
    command -v brew > /dev/null 2>&1 || {
        printf "\033[31m错误: 未安装 Homebrew\033[0m\n"
        return 1
    }

    local mirror="${1:-$(select_mirror)}"
    [[ -n "$mirror" ]] && apply_mirror "$mirror"
}

# 直接执行时运行
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && cn_brew "$@"
