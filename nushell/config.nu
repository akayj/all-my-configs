$env.config = {
    show_banner: false
    completions: {
        algorithm: "fuzzy"
        case_sensitive: false
    }
    error_style: "fancy"
}

# 环境变量
# $env.GITHUB_TOKEN = ""  # 请在本地环境中设置
$env.NVM_DIR = $"($env.HOME)/.nvm"
$env.BUN_INSTALL = $"($env.HOME)/.bun"
$env.TERM = "xterm-256color"

$env.PATH = ($env.PATH | prepend [
    $"($env.HOME)/.opencode/bin"
    $"($env.HOME)/.bun/bin"
    $"($env.HOME)/.moon/bin"
])

def "go-version" [] {
    go version | split row " " | get 2
}

def create_prompt [] {
    let dir = (pwd | path basename)

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

$env.PROMPT_COMMAND = { create_prompt }


# 导入模块
use modules/wd.nu *
use modules/git.nu *