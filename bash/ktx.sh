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

            cur=$(echo "$ctx_list" \
                                   | fzf --prompt='context> ' \
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
            cur=$(echo "$ns_list" \
                                  | fzf --prompt='namespace> ' \
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

# 查看pod日志
klog() {
    local namespace pod pod_list opts follow
    follow=""
    opts=""

    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -f)
                follow="-f"
                shift
                ;;
            -*)
                opts="$opts $1"
                shift
                ;;
            *)
                # 第一个非选项参数作为namespace，第二个作为pod
                if [[ -z $namespace ]]; then
                    namespace="$1"
                elif [[ -z $pod ]]; then
                    pod="$1"
                fi
                shift
                ;;
        esac
    done

    # 如果没有指定namespace，先尝试使用当前上下文的namespace
    if [[ -z $namespace ]]; then
        local current_ns
        current_ns=$(kubectl config view --minify -o jsonpath='{..namespace}' 2> /dev/null)
        if [[ -n $current_ns ]]; then
            namespace="$current_ns"
        else
            local ns_list
            ns_list=$(kubectl get ns -o name 2> /dev/null | sed 's|namespace/||')
            [[ -z $ns_list ]] && {
                echo "no namespaces found"
                return 1
            }
            if command -v fzf > /dev/null 2>&1; then
                namespace=$(echo "$ns_list" \
                                            | fzf --prompt='namespace> ' \
                        --height=40% --reverse --border \
                        --preview 'kubectl get pods -n {} --no-headers 2>/dev/null | head -20' \
                        --preview-window 'right:50%:wrap' \
                        --bind 'ctrl-r:refresh-preview' \
                        --bind 'focus:refresh-preview' \
                        --bind "alt-r:toggle-raw" \
                        --bind 'ctrl-/:toggle-preview')
            else
                select namespace in $ns_list; do break; done
            fi
            [[ -z $namespace ]] && return 1
        fi
    fi

    # 如果没有指定pod，交互式选择
    if [[ -z $pod ]]; then
        pod_list=$(kubectl get pods -n "$namespace" -o name 2> /dev/null | sed 's|pod/||')
        [[ -z $pod_list ]] && {
            echo "no pods found in namespace $namespace"
            return 1
        }
        if command -v fzf > /dev/null 2>&1; then
            pod=$(echo "$pod_list" \
                                   | fzf --prompt='pod> ' \
                    --height=40% --reverse --border \
                    --preview "kubectl describe pod -n $namespace {} 2>/dev/null" \
                    --preview-window 'right:60%:wrap' \
                    --bind 'ctrl-r:refresh-preview' \
                    --bind 'focus:refresh-preview' \
                    --bind "alt-r:toggle-raw" \
                    --bind 'ctrl-/:toggle-preview')
        else
            select pod in $pod_list; do break; done
        fi
        [[ -z $pod ]] && return 1
    fi

    # 输出日志
    kubectl logs -n "$namespace" $follow $opts "$pod"
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

# klog补全函数
_klog_completion() {
    local cur prev opts i non_option_count namespace
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD - 1]}"

    # 计算非选项参数的数量
    non_option_count=0
    namespace=""
    for ((i = 1; i < COMP_CWORD; i++)); do
        if [[ ${COMP_WORDS[i]} != -* ]]; then
            ((non_option_count++))
            if [[ $non_option_count -eq 1 ]]; then
                namespace="${COMP_WORDS[i]}"
            fi
        fi
    done

    # 如果当前单词是选项，不补全
    if [[ $cur == -* ]]; then
        # 可以补全常用选项，这里简单处理
        opts="-f --tail --since --timestamps --previous"
        COMPREPLY=($(compgen -W "$opts" -- "$cur"))
        return 0
    fi

    # 根据非选项参数数量决定补全
    case $non_option_count in
        0)
            # 第一个非选项参数，补全namespace
            opts=$(kubectl get ns -o name 2> /dev/null | sed 's|namespace/||')
            ;;
        1)
            # 第二个非选项参数，补全pod
            if [[ -n $namespace ]]; then
                opts=$(kubectl get pods -n "$namespace" -o name 2> /dev/null | sed 's|pod/||')
            fi
            ;;
        *)
            # 已经有足够的参数，不补全
            ;;
    esac

    COMPREPLY=($(compgen -W "${opts}" -- "$cur"))
    return 0
}

# 注册补全函数
complete -F _ktx_completion ktx
complete -F _kns_completion kns
complete -F _klog_completion klog
