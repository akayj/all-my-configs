#!/usr/bin/env bash

set -eu

declare -A plugins
plugins=(
  [you-should-use]=MichaelAquilina/zsh-you-should-use
  [F-Sy-H]=z-shell/F-Sy-H
  [zsh-autosuggestions]=zsh-users/zsh-autosuggestions
  [zsh-syntax-highlighting]=zsh-users/zsh-syntax-highlighting
)

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

for name in ${!plugins[@]}; do
  if [ ! -d "$ZSH_CUSTOM/plugins/$name" ]; then
    git clone --depth=1 "https://github.com/${plugins[$name]}.git" "$ZSH_CUSTOM/plugins/$name"
  else
    echo "$name already installed"
  fi
done
