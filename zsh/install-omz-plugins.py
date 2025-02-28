import os
import subprocess

# 定义插件列表，每个插件包含名称和仓库地址
plugins = [
    {"name": "you-should-use", "repo": "MichaelAquilina/zsh-you-should-use"},
    {"name": "F-Sy-H", "repo": "z-shell/F-Sy-H"},
    {"name": "zsh-autosuggestions", "repo": "zsh-users/zsh-autosuggestions"},
    {"name": "zsh-syntax-highlighting", "repo": "zsh-users/zsh-syntax-highlighting"}
]

# 设置自定义ZSH路径
ZSH_CUSTOM = os.getenv("ZSH_CUSTOM", os.path.join(os.path.expanduser("~"), ".oh-my-zsh/custom"))

# 确保插件目录存在
os.makedirs(os.path.join(ZSH_CUSTOM, "plugins"), exist_ok=True)

# 遍历插件列表
for plugin in plugins:
    name = plugin["name"]
    repo = plugin["repo"]
    plugin_dir = os.path.join(ZSH_CUSTOM, "plugins", name)

    # 检查插件是否已安装
    if not os.path.isdir(plugin_dir):
        # 构建完整的仓库地址
        repo_url = f"https://github.com/{repo}.git"
        # 使用git clone克隆仓库
        try:
            subprocess.run(["git", "clone", "--depth=1", repo_url, plugin_dir], check=True)
            print(f"{name} installed successfully")
        except subprocess.CalledProcessError as e:
            print(f"Failed to install {name}: {e}")
    else:
        print(f"{name} already installed")
