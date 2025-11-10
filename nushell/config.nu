# Nushell 配置入口文件
# 
# 配置文件结构说明：
# - config.nu: 主配置入口，只包含基础配置和模块导入
# - modules/env.nu: 环境变量配置
# - modules/prompt.nu: 提示符配置
# - modules/aliases.nu: 命令别名和快捷方式
# - modules/wd.nu: 工作目录快捷跳转
# - modules/git.nu: Git 相关功能
# - env.nu.example: 本地环境变量模板（不提交到版本控制）

# ============================================
# 基础配置
# ============================================
$env.config = {
    show_banner: false
    completions: {
        algorithm: "fuzzy"
        case_sensitive: false
    }
    error_style: "fancy"
}

# ============================================
# 导入模块
# ============================================
use modules/env.nu *      # 环境变量配置
use modules/prompt.nu *   # 提示符配置
use modules/aliases.nu *  # 命令别名
use modules/wd.nu *       # 工作目录管理
use modules/git.nu *      # Git 功能

# ============================================
# 本地环境变量
# ============================================
# 注意：敏感信息（如 GITHUB_TOKEN）应该放在 ~/.config/nushell/env.nu 中
# 该文件不会被版本控制，请参考 env.nu.example