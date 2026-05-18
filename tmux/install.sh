#!/bin/sh
BASEDIR=$(cd "$(dirname "$0")" && pwd)

echo "Installing tmux config from $BASEDIR..."

# 安装 tmux（如果未安装）
sh "$BASEDIR/../tool.sh" tmux

# 移除旧的 Oh My Tmux symlink
rm -f ~/.tmux.conf ~/.tmux.conf.local

# 创建 XDG 应用目录
mkdir -p ~/.config/tmux

# 创建 symlink（配置文件）
ln -sf "$BASEDIR/tmux.conf" ~/.config/tmux/tmux.conf
ln -sf "$BASEDIR/conf.d" ~/.config/tmux/conf.d
ln -sf "$BASEDIR/scripts" ~/.config/tmux/scripts

# 安装 TPM（如果未安装）
if [ ! -d ~/.config/tmux/plugins/tpm ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
fi

# 安装 TPM 插件
~/.config/tmux/plugins/tpm/bin/install_plugins
