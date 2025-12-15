# 自动安装 fzf（若未装）
_ensure_fzf() {
    FZF_LOCAL="$HOME/.local/bin/fzf"
    if ! command -v fzf &> /dev/null && [ ! -x "$FZF_LOCAL" ]; then
        echo "fzf not found, downloading latest release ..."
        mkdir -p "$HOME/.local/bin"

        # 自动检测 OS / arch
        case "$(uname -s)" in
            Linux*) FZF_OS="linux" ;;
            Darwin*) FZF_OS="darwin" ;;
            *)
                echo "Unsupported OS"
                return 1
                ;;
        esac
        case "$(uname -m)" in
            x86_64) FZF_ARCH="amd64" ;;
            aarch64 | arm64) FZF_ARCH="arm64" ;;
            *)
                echo "Unsupported arch"
                return 1
                ;;
        esac

        # 通过 GitHub API 直接获取对应平台的下载链接
        echo "Fetching latest fzf release for ${FZF_OS}_${FZF_ARCH}..."
        FZF_URL=$(curl -fsSL https://api.github.com/repos/junegunn/fzf/releases/latest \
            | grep "browser_download_url.*fzf-.*-${FZF_OS}_${FZF_ARCH}.tar.gz" \
            | sed -E 's/.*"browser_download_url": *"([^"]+)".*/\1/')

        if [ -z "$FZF_URL" ]; then
            echo "Failed to fetch download URL from GitHub API"
            return 1
        fi

        printf "Downloading %s ...\n" "$FZF_URL"
        if curl -fL "$FZF_URL" -o /tmp/fzf.tgz; then
            tar -xf /tmp/fzf.tgz -C "$HOME/.local/bin" fzf
            chmod +x "$HOME/.local/bin/fzf"
            rm /tmp/fzf.tgz
            printf "fzf %s installed successfully to %s\n" "$($FZF_LOCAL --version)" "$FZF_LOCAL"
        else
            echo "Failed to download fzf"
            rm -f /tmp/fzf.tgz
            return 1
        fi
    fi
    # 确保在 PATH
    export PATH="$HOME/.local/bin:$PATH"
}

# Git fzf log 主函数
git_fzf_log() {
    # 检查是否在 Git 仓库中
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "错误：当前目录不是 Git 仓库"
        return 1
    fi

    # 确保 fzf 已安装
    _ensure_fzf

    # 颜色变量
    _diff_preview_window="right:60%:wrap"
    _log_format="%C(yellow)%h %C(cyan)%ad %C(blue)%an%C(reset): %s"
    _date_format="format:%Y-%m-%d %H:%M"

    # 主界面：列出最近 500 条日志
    #    传入的 $1 作为初始查询词
    #    注意：git log 默认倒序（最新在上），fzf 用 --layout=reverse 只改界面布局不改行顺序
    commit=$(git log --color=always --date="$_date_format" --pretty="tformat:$_log_format" -500 | fzf --ansi \
            --layout=reverse --height=100% \
            --header "↑↓ 选择 / Ctrl-S diff-stat / Ctrl-Y show / Ctrl-O checkout" \
            --bind "ctrl-s:execute-silent(git show --color=always --stat {1})+abort" \
            --bind "ctrl-y:execute(git show --color=always {1})" \
            --bind "ctrl-o:execute(git checkout {1})" \
            --bind "alt-r:toggle-raw" \
            --preview "git diff --color=always {1}~1..{1}" \
            --preview-window "$_diff_preview_window" \
            --query "${1:-}" | awk '{print $1}')

    # 二级菜单：对选中的 commit 再操作
    [ -z "$commit" ] && return 0

    action=$(printf "diff\nshow\nstat\ncheckout\nquit" | fzf --header "Commit: $commit" --reverse --height=25% | tr -d '\r')

    case "$action" in
        diff) git diff --color=always "$commit"~1.."$commit" | less -R ;;
        show) git show --color=always "$commit" | less -R ;;
        stat) git show --color=always --stat "$commit" | less -R ;;
        checkout)
            read -rp "Really checkout $commit? [y/N] " ok
            case "$ok" in
                [Yy] | [Yy][Ee][Ss]) git checkout "$commit" ;;
                *) ;;
            esac
            ;;
        quit | "") ;;
    esac
}

# 创建别名，方便调用
alias glf='git_fzf_log'
