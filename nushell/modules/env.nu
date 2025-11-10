# 环境变量配置模块

# 加载可选的环境变量文件
def load-env-vars [] {
    try {
        source ~/.config/nushell/env.nu
        print "已加载环境变量文件"
    } catch { |e|
        print $"加载环境变量文件失败: ($e)"
    }
}

# 设置环境变量
export-env {
    # 基础路径配置
    $env.NVM_DIR = $"($env.HOME)/.nvm"
    $env.BUN_INSTALL = $"($env.HOME)/.bun"
    $env.TERM = "xterm-256color"

    # PATH 配置
    $env.PATH = ($env.PATH | prepend [
        $"($env.HOME)/.opencode/bin"
        $"($env.HOME)/.bun/bin"
        $"($env.HOME)/.moon/bin"
    ])

    # 其他环境变量
    load-env {
        CARGO_TARGET_DIR: "~/.cargo/target"
        EDITOR: "vim"
        VISUAL: "vim"
        PAGER: "less"
        JULIA_NUM_THREADS: nproc
        HOSTNAME: (hostname | split row '.' | first | str trim)
        SHOW_USER: true
        LS_COLORS: ([
            "di=01;34;2;102;217;239"
            "or=00;40;31"
            "mi=00;40;31"
            "ln=00;36"
            "ex=00;32"
        ] | str join (char env_sep))
    }
}
