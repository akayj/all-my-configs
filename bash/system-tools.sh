#!/usr/bin/env bash

# 进程查找和管理函数
pff() {
    if [[ $# -eq 0 ]]; then
        # 无参数时，显示所有进程供选择
        local selected_process
        selected_process=$(ps aux | fzf --header="选择进程查看详情 (Ctrl+C 退出)" \
            --height=60% --reverse --border \
            --preview 'echo "PID: {2} | 用户: {1} | CPU: {3}% | 内存: {4}%"; ps -p {2} -o pid,ppid,cmd,lstart,etime --no-headers 2>/dev/null || echo "进程可能已结束"' \
            --bind 'ctrl-k:execute-silent(kill {2})+reload(ps aux)' \
            --bind 'ctrl-x:execute-silent(kill -9 {2})+reload(ps aux)' \
            --bind 'alt-r:toggle-raw' \
            --preview-window=right:50%:wrap)

        [[ -n $selected_process ]] && echo "选中进程: $selected_process"
    else
        # 有参数时，模糊搜索进程
        local search_term="$1"
        local matching_processes
        matching_processes=$(ps aux | grep -i "$search_term" | grep -v grep | fzf --header="搜索结果: $search_term" \
            --height=60% --reverse --border \
            --preview 'echo "PID: {2} | 用户: {1} | CPU: {3}% | 内存: {4}%"; ps -p {2} -o pid,ppid,cmd,lstart,etime --no-headers 2>/dev/null || echo "进程可能已结束"' \
            --bind 'ctrl-k:execute-silent(kill {2})+reload(ps aux | grep -i "'$search_term'" | grep -v grep)' \
            --bind 'ctrl-x:execute-silent(kill -9 {2})+reload(ps aux | grep -i "'$search_term'" | grep -v grep)' \
            --bind 'alt-r:toggle-raw' \
            --preview-window=right:50%:wrap)

        [[ -n $matching_processes ]] && echo "匹配进程: $matching_processes"
    fi
}

# 端口占用查找
portff() {
    if [[ $# -eq 0 ]]; then
        echo "用法: portff <端口号> 或 portff (列出所有监听端口)"
        return 1
    fi

    local port="$1"
    local process_info
    process_info=$(lsof -i ":$port" 2> /dev/null | fzf --header="端口 $port 占用情况" \
        --height=40% --reverse --border \
        --preview 'echo "进程详情:"; ps -p {2} -o pid,ppid,cmd,lstart,etime --no-headers 2>/dev/null || echo "无法获取进程信息"' \
        --bind 'ctrl-k:execute-silent(kill {2})+reload(lsof -i :'$port')' \
        --bind 'alt-r:toggle-raw' \
        --preview-window=right:50%:wrap)

    [[ -z $process_info ]] && echo "端口 $port 未被占用"
}

# 历史命令搜索
hff() {
    local selected_command
    selected_command=$(history | fzf --header="选择历史命令 (Enter执行, Ctrl-Y复制)" \
        --height=60% --reverse --border \
        --bind 'ctrl-y:execute-silent(echo {2} | pbcopy)+abort' \
        --bind 'enter:execute(echo "{2}")+abort' \
        --bind 'alt-r:toggle-raw' \
        --preview 'echo "命令: {2}"; echo "执行时间: {1}"' \
        --preview-window=right:50%:wrap)

    if [[ -n $selected_command ]]; then
        local cmd=$(echo "$selected_command" | awk '{$1=""; print substr($0,2)}')
        echo "执行: $cmd"
        eval "$cmd"
    fi
}

# 文件快速查找和操作
fff() {
    local search_path="${1:-.}"
    local selected_file
    selected_file=$(find "$search_path" -type f -not -path '*/\.git/*' -not -path '*/node_modules/*' 2> /dev/null | fzf \
        --header="选择文件操作 (Enter编辑, Ctrl+O打开, Ctrl+Y复制路径)" \
        --height=60% --reverse --border \
        --preview 'file {}; echo "---"; head -20 {} 2>/dev/null || echo "文件过大或无法读取"' \
        --bind 'enter:execute(${EDITOR:-vi} {})+abort' \
        --bind 'ctrl-o:execute(open {} 2>/dev/null || xdg-open {} 2>/dev/null)+abort' \
        --bind 'ctrl-y:execute-silent(echo {} | pbcopy)+abort' \
        --bind 'ctrl-d:execute-silent(rm -i {})+reload(find "'$search_path'" -type f -not -path "*/\.git/*" -not -path "*/node_modules/*" 2>/dev/null)' \
        --bind 'alt-r:toggle-raw' \
        --preview-window=right:60%:wrap)

    [[ -n $selected_file ]] && echo "已选择文件: $selected_file"
}

# 安装包管理器快速查找 (支持不同系统)
pkgf() {
    local pkg_manager=""
    local search_term="$1"

    # 检测包管理器
    if command -v brew &> /dev/null; then
        pkg_manager="brew"
    elif command -v apt &> /dev/null; then
        pkg_manager="apt"
    elif command -v yum &> /dev/null; then
        pkg_manager="yum"
    elif command -v pacman &> /dev/null; then
        pkg_manager="pacman"
    else
        echo "不支持的包管理器"
        return 1
    fi

    if [[ -z $search_term ]]; then
        echo "用法: pkgf <搜索关键词>"
        echo "当前包管理器: $pkg_manager"
        return 1
    fi

    case "$pkg_manager" in
        "brew")
            local selected_pkg=$(brew search "$search_term" | fzf --header="选择包 (Enter安装)" --height=50% --reverse --border \
                --bind 'enter:execute-silent(brew install {})+abort')
            [[ -n $selected_pkg ]] && echo "已安装: $selected_pkg"
            ;;
        "apt")
            local selected_pkg=$(apt search "$search_term" 2> /dev/null | fzf --header="选择包 (Enter安装)" --height=50% --reverse --border \
                --preview 'apt show {1} 2>/dev/null | head -20' \
                --preview-window=right:60%:wrap \
                --bind 'enter:execute-silent(sudo apt install -y {1})+abort')
            [[ -n $selected_pkg ]] && echo "已安装: $selected_pkg"
            ;;
        "yum")
            local selected_pkg=$(yum search "$search_term" 2> /dev/null | fzf --header="选择包 (Enter安装)" --height=50% --reverse --border \
                --preview 'yum info {1} 2>/dev/null | head -20' \
                --preview-window=right:60%:wrap \
                --bind 'enter:execute-silent(sudo yum install -y {1})+abort')
            [[ -n $selected_pkg ]] && echo "已安装: $selected_pkg"
            ;;
        "pacman")
            local selected_pkg=$(pacman -Ss "$search_term" | fzf --header="选择包 (Enter安装)" --height=50% --reverse --border \
                --preview 'pacman -Si {1} 2>/dev/null | head -20' \
                --preview-window=right:60%:wrap \
                --bind 'enter:execute-silent(sudo pacman -S {1})+abort')
            [[ -n $selected_pkg ]] && echo "已安装: $selected_pkg"
            ;;
    esac
}

# 补全函数
_pff_completion() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"

    # 可以补全搜索关键词
    COMPREPLY=($(compgen -c -- ${cur}))
    return 0
}

_pkgf_completion() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"

    # 可以补全搜索关键词
    COMPREPLY=($(compgen -c -- ${cur}))
    return 0
}

# 注册补全 (仅在 bash 环境下)
if [[ -n $BASH_VERSION ]]; then
    complete -F _pff_completion pff
    complete -F _pkgf_completion pkgf
fi

echo "系统工具函数已加载: pff, portff, hff, fff, pkgf"
