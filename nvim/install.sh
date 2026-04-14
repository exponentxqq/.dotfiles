#!/bin/bash

# Neovim 配置安装脚本

set -e

echo "开始安装 Neovim 配置..."

# 创建必要的目录
mkdir -p ~/.cache/nvim/undo

# 创建符号链接 - 整个 config 目录
ln -sfn ~/develop/dotfiles/nvim/config ~/.config/nvim

echo "安装完成！"
echo ""
echo "符号链接已创建："
echo "  ~/.config/nvim -> ~/develop/dotfiles/nvim/config"
echo ""
echo "下一步操作："
echo "1. 启动 Neovim，它会自动安装 lazy.nvim"
echo "2. 运行 :Lazy sync 安装所有插件"
echo ""
echo "提示：可通过 :ReloadConfig 重新加载配置"
