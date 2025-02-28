#!/usr/bin/env python3
import os
import subprocess
from dataclasses import dataclass


@dataclass
class Plugin:
    name: str
    repo: str


# 定义插件列表，每个插件包含名称和仓库地址
plugins = [
    Plugin('you-should-use', 'MichaelAquilina/zsh-you-should-use'),
    Plugin('F-Sy-H', 'z-shell/F-Sy-H'),
    Plugin('zsh-autosuggestions', 'zsh-users/zsh-autosuggestions'),
    Plugin('zsh-syntax-highlighting', 'zsh-users/zsh-syntax-highlighting'),
]

# 设置自定义ZSH路径
ZSH_CUSTOM = os.getenv('ZSH_CUSTOM', os.path.expanduser('~/.oh-my-zsh/custom'))
ZSH_CUSTOM_PLUGIN_BASE = os.path.join(ZSH_CUSTOM, 'plugins')

# 确保插件目录存在
os.makedirs(ZSH_CUSTOM_PLUGIN_BASE, exist_ok=True)

# 遍历插件列表
for plugin in plugins:
    name = plugin.name
    repo = plugin.repo

    plugin_dir = os.path.join(ZSH_CUSTOM_PLUGIN_BASE, name)

    # 检查插件是否已安装
    if not os.path.isdir(plugin_dir):
        # 构建完整的仓库地址
        repo_url = f'https://github.com/{repo}.git'
        # 使用git clone克隆仓库
        try:
            subprocess.run(['git', 'clone', '--depth=1', repo_url, plugin_dir], check=True)
            print(f'{name} installed successfully')
        except subprocess.CalledProcessError as e:
            print(f'Failed to install {name}: {e}')
    else:
        print(f'{name} already installed')
