# 命令别名和快捷方式

# ls 相关命令，方便按照不同方式排序
export def ls-size [] { ls | sort-by size }
export def ls-time [] { ls | sort-by modified }
export def ls-reverse [] { ls | reverse }
export def ls-long [] { ls -l }
export def ls-all [] { ls -a }

# Git diff 使用 difft
export def egd [...rest] {
    with-env [GIT_EXTERNAL_DIFF 'difft'] { git diff $rest }
}

# Go 版本信息
export def go-version [] {
    go version | split row " " | get 2
}

# Kubectl 别名
export alias k = kubectl
export alias kg = kubectl get
export alias kd = kubectl describe
export alias kdel = kubectl delete
export alias kl = kubectl logs
export alias ka = kubectl apply
export alias kex = kubectl exec
export alias kgpo = kubectl get pods
export alias kgd = kubectl get deployments
export alias kgsvc = kubectl get services
export alias kgn = kubectl get nodes
export alias kgns = kubectl get namespaces
export alias kgcm = kubectl get configmaps
export alias kgs = kubectl get secrets
export alias kging = kubectl get ingress
export alias kctx = kubectl config current-context
export alias kns = kubectl config set-context --current --namespace
