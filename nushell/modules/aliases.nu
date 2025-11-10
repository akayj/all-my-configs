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
