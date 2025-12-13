# 1. 自动安装 fzf（若未装）
FZF_URL_BASE="https://github.com/junegunn/fzf/releases/download"
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
            exit 1
            ;;
    esac
    case "$(uname -m)" in
        x86_64) FZF_ARCH="amd64" ;;
        aarch64 | arm64) FZF_ARCH="arm64" ;;
        *)
            echo "Unsupported arch"
            exit 1
            ;;
    esac
    FZF_TAR="fzf_${FZF_OS}_${FZF_ARCH}.tar.gz"
    curl -L "$FZF_URL_BASE/latest/$FZF_TAR" -o /tmp/fzf.tgz
    tar -xf /tmp/fzf.tgz -C "$HOME/.local/bin" fzf
    rm /tmp/fzf.tgz
fi
# 确保在 PATH
export PATH="$HOME/.local/bin:$PATH"

# 2. 颜色变量
_diff_preview_window="right:60%:wrap"
_log_format="%C(yellow)%h %C(cyan)%ad %C(blue)%an%C(reset): %s"
_date_format="format:%Y-%m-%d %H:%M"

# 3. 主界面：列出最近 500 条日志
#    传入的 $1 作为初始查询词
commit=$(git log --color=always --date="$_date_format" --pretty="tformat:$_log_format" -500 |
    fzf --ansi \
        --reverse --height=100% \
        --header "↑↓ 选择 / Ctrl-S diff-stat / Ctrl-Y show / Ctrl-O checkout" \
        --bind "ctrl-s:execute-silent(git show --color=always --stat {1})+abort" \
        --bind "ctrl-y:execute(git show --color=always {1})" \
        --bind "ctrl-o:execute(git checkout {1})" \
        --bind "alt-r:toggle-raw" \
        --preview "git diff --color=always {1}~1..{1}" \
        --preview-window "$_diff_preview_window" \
        --query "${1:-}" |
    awk '{print $1}')

# 4. 二级菜单：对选中的 commit 再操作
[ -z "$commit" ] && exit 0

action=$(printf "diff\nshow\nstat\ncheckout\nquit" |
    fzf --header "Commit: $commit" --reverse --height=25% |
    tr -d '\r')

case "$action" in
    diff) git diff --color=always "$commit"~1.."$commit" | less -R ;;
    show) git show --color=always "$commit" | less -R ;;
    stat) git show --color=always --stat "$commit" | less -R ;;
    checkout)
        read -rp "Really checkout $commit? [y/N] " ok
        [[ $ok =~ ^[Yy]$ ]] && git checkout "$commit"
        ;;
    quit | "") ;;
esac
