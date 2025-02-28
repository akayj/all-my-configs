#!/usr/bin/env bash

set -eu

# 使用普通数组来存储键值对
plugins=(
  "you-should-use MichaelAquilina/zsh-you-should-use"
  "F-Sy-H z-shell/F-Sy-H"
  "zsh-autosuggestions zsh-users/zsh-autosuggestions"
  "zsh-syntax-highlighting zsh-users/zsh-syntax-highlighting"
)

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

for plugin in "${plugins[@]}"; do
  # 分割键值对
  IFS=' ' read -r name repo <<< "$plugin"
  if [ ! -d "$ZSH_CUSTOM/plugins/$name" ]; then
    git clone --depth=1 "https://github.com/$repo.git" "$ZSH_CUSTOM/plugins/$name"
  else
    echo "$name already installed"
  fi
done
