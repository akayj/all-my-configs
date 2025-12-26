ktx() {
    local cur ctx_list
    # 取出所有 context 名
    ctx_list=$(kubectl config get-contexts -o name 2> /dev/null)
    [[ -z $ctx_list ]] && {
        echo "no contexts found"
        return 1
    }

    # 如果带参数，直接切换；否则交互式选
    if [[ -n $1 ]]; then
        kubectl config use-context "$1" && echo "✔  switched to <$1>"
    else
        # fzf 可用就用它，不可用退而求其次用 select
        if command -v fzf > /dev/null 2>&1; then
            # 根据工具可用性选择预览命令
            if command -v jq > /dev/null 2>&1; then
                preview_cmd='CTX={} && kubectl config view --raw -o json | jq --arg ctx "$CTX" ".contexts[] | select(.name == \$ctx)"'
            else
                preview_cmd='kubectl config view --minify --context={}'
            fi

            cur=$(echo "$ctx_list" |
                fzf --prompt='context> ' \
                    --height=40% --reverse --border \
                    --preview "$preview_cmd" \
                    --bind "alt-r:toggle-raw" \
                    --bind 'ctrl-/:toggle-preview')
        else
            select cur in $ctx_list; do break; done
        fi
        [[ -n $cur ]] && kubectl config use-context "$cur" && echo "✔  switched to <$cur>"
    fi
}

# 可选：kubens 也一样
kns() {
    local cur ns_list
    ns_list=$(kubectl get ns -o name 2> /dev/null | sed 's|namespace/||')
    [[ -z $ns_list ]] && {
        echo "no namespaces found"
        return 1
    }

    if [[ -n $1 ]]; then
        kubectl config set-context --current --namespace="$1" && echo "✔  set namespace to <$1>"
    else
        if command -v fzf > /dev/null 2>&1; then
            cur=$(echo "$ns_list" |
                fzf --prompt='namespace> ' \
                    --height=40% --reverse --border \
                    --header='↑↓: 切换namespace | ctrl-r: 刷新pod列表 | ctrl-/: 切换预览' \
                    --preview 'kubectl get pods -n {} --no-headers 2>/dev/null | head -20' \
                    --preview-window 'right:50%:wrap' \
                    --bind 'ctrl-r:refresh-preview' \
                    --bind 'focus:refresh-preview' \
                    --bind "alt-r:toggle-raw" \
                    --bind 'ctrl-/:toggle-preview')
        else
            select cur in $ns_list; do break; done
        fi
        [[ -n $cur ]] && kubectl config set-context --current --namespace="$cur" && echo "✔  set namespace to <$cur>"
    fi
}

# ktx补全函数
_ktx_completion() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD - 1]}"

    # 获取所有可用的context
    opts=$(kubectl config get-contexts -o name 2> /dev/null)

    COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
    return 0
}

# kns补全函数
_kns_completion() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD - 1]}"

    # 获取所有可用的namespace
    opts=$(kubectl get ns -o name 2> /dev/null | sed 's|namespace/||')

    COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
    return 0
}

# 注册补全函数
complete -F _ktx_completion ktx
complete -F _kns_completion kns
