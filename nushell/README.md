# Nushell 配置

这是一个功能丰富的 Nushell 配置，包含了许多实用的命令和环境设置。

## 功能特性

- 自定义提示符，显示当前目录和 Git 分支
- 目录书签管理 (wd)
- Git 辅助命令
- 便捷的 ls 别名，支持按大小、时间排序
- 支持敏感环境变量配置
- 可通过软链接在系统上使用

## 安装

### 前提条件

确保已安装 Nushell。如果没有安装，可以通过以下方式安装：

```bash
# macOS 使用 Homebrew
brew install nushell

# 或者使用 Cargo
cargo install nu
```

### 安装步骤

1. 克隆此仓库：

```bash
git clone https://github.com/your-username/all-my-configs.git
cd all-my-configs/nushell
```

2. 运行安装脚本：

```bash
chmod +x install.sh
./install.sh
```

安装脚本将会：

- 创建软链接将配置文件连接到 `~/.config/nushell/`（或 `$XDG_CONFIG_HOME/nushell/`）
- 备份任何现有的配置文件
- 创建示例 `env.nu` 文件
- 创建空的 `wd_bookmarks.json` 文件

### 手动安装

如果不想使用安装脚本，也可以手动创建软链接：

```bash
# 创建配置目录
mkdir -p ~/.config/nushell

# 创建软链接
ln -s /path/to/all-my-configs/nushell/config.nu ~/.config/nushell/config.nu
ln -s /path/to/all-my-configs/nushell/modules ~/.config/nushell/modules

# 创建环境变量文件
cp /path/to/all-my-configs/nushell/env.nu.example ~/.config/nushell/env.nu

# 创建书签文件
touch ~/.config/nushell/wd_bookmarks.json
```

## 配置

### 环境变量

编辑 `~/.config/nushell/env.nu` 文件来添加敏感环境变量：

```nu
# 示例环境变量
$env.GITHUB_TOKEN = "your-github-token-here"
$env.API_KEY = "your-api-key-here"
```

### 启动 Nushell

安装完成后，直接使用 `nu` 命令启动 Nushell。启动后，可以使用以下方式加载环境变量：

1. 使用 `load-env-vars` 命令加载环境变量：

```bash
nu
load-env-vars
```

2. 或者手动加载环境变量：

```bash
nu
source ~/.config/nushell/env.nu
```

注意：由于 Nushell 的限制，环境变量不会在启动时自动加载，需要手动执行上述命令之一。

### 目录书签 (wd)

wd 模块提供了目录书签功能，类似于 oh-my-zsh 的 wd 插件：

```bash
# 添加当前目录为书签
wd add [name]

# 跳转到书签
wd <name>

# 列出所有书签
wd list

# 删除书签
wd rm <name>

# 显示当前目录的书签
wd show

# 清空所有书签
wd clean

# 显示帮助
wd help
```

### Git 辅助命令

配置包含了许多实用的 Git 辅助命令：

```bash
# 短格式状态
git status-short

# 单行日志
git log-oneline [count]

# 快速提交
git commit-quick "message"

# 推送当前分支
git push-current

# 拉取当前分支
git pull-current

# 显示当前分支
git current-branch

# 列出所有分支
git branches

# 创建并切换到新分支
git new-branch <name>

# 删除分支
git delete-branch <name>

# 强制删除分支
git delete-branch-force <name>

# 彩色差异
git diff-color

# 带统计的日志
git log-stats [count]

# Git 图形日志
git log-graph [count]
```

### 别名

配置中包含了一些实用的别名：

#### Git 别名

```bash
gs  # git status-short
gl  # git log-oneline
gp  # git push-current
gpl # git pull-current
gc  # git commit-quick
gb  # git current-branch
gd  # git diff
ga  # git add
```

#### ls 别名

```bash
ls-size    # 按文件大小排序
ls-time    # 按修改时间排序
ls-reverse # 反向显示文件列表
ls-long    # 显示详细信息
ls-all     # 显示所有文件（包括隐藏文件）
```

这些别名通过管道和 Nushell 的 `sort-by` 命令实现排序功能，使文件列表更加灵活和有用。

## 文件结构

```
nushell/
├── config.nu          # 主配置文件，包含所有配置和命令
├── modules/           # 模块目录
│   ├── wd.nu          # 目录书签模块
│   └── git.nu         # Git 辅助命令模块
├── env.nu.example     # 环境变量示例文件
├── install.sh         # 安装脚本
├── .gitignore         # Git 忽略文件
└── README.md          # 本文档
```

## 注意事项

- `wd_bookmarks.json` 和 `env.nu` 文件被配置为不被版本控制，以保护敏感信息和用户特定数据
- 配置文件支持 XDG Base Directory 规范，会优先使用 `$XDG_CONFIG_HOME/nushell/` 目录
- 安装脚本会备份任何现有的配置文件，以防止意外覆盖
- 由于 Nushell 的限制，环境变量不会在启动时自动加载，需要手动执行 `load-env-vars` 命令或 `source ~/.config/nushell/env.nu`

## 更新配置

如果更新了配置文件，只需重新启动 Nushell 或运行以下命令：

```nu
source ~/.config/nushell/config.nu
source ~/.config/nushell/env.nu  # 如果需要重新加载环境变量
```

## 卸载

要卸载此配置，只需删除软链接：

```bash
rm ~/.config/nushell/config.nu
rm ~/.config/nushell/init.nu
rm ~/.config/nushell/modules

# 可选：删除整个配置目录
# rm -rf ~/.config/nushell
```
