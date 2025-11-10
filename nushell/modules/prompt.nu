# 提示符配置模块

# 构建提示符
export def build-prompt [] {
    let dir = (pwd | path basename)

    # 获取 Git 分支信息
    let git_info = (do {
        git rev-parse --abbrev-ref HEAD
    } | complete)

    if $git_info.exit_code == 0 {
        let git_branch = ($git_info.stdout | str trim)
        $"($dir) \(($git_branch)) > "
    } else {
        $"($dir) > "
    }
}

# 设置提示符环境变量
export-env {
    $env.PROMPT_COMMAND = { build-prompt }
}
