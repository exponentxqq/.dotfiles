#!/bin/sh

BASEDIR=$(
  cd "$(dirname "$0")"
  pwd
)

echo --------------------------------------------------------
echo ---- install claude code config from "$BASEDIR" ----
echo --------------------------------------------------------

# 确保 ~/.claude 目录存在
mkdir -p ~/.claude

# 备份并 symlink settings.json
if [ -f ~/.claude/settings.json ] && [ ! -L ~/.claude/settings.json ]; then
  mv ~/.claude/settings.json ~/.claude/settings.json.bak
  echo "Backed up existing settings.json to settings.json.bak"
fi
ln -sf "$BASEDIR/settings.json" ~/.claude/settings.json

# 备份并 symlink skills 目录
if [ -d ~/.claude/skills ] && [ ! -L ~/.claude/skills ]; then
  mv ~/.claude/skills ~/.claude/skills.bak
  echo "Backed up existing skills/ to skills.bak"
fi
ln -sfn "$BASEDIR/skills" ~/.claude/skills

# 创建 settings.local.json（如果不存在），不覆盖已有文件
if [ ! -f ~/.claude/settings.local.json ]; then
  cp "$BASEDIR/settings.local.example.json" ~/.claude/settings.local.json
  echo "Created settings.local.json from example — edit it to add your API keys"
fi

# 安装插件
if [ -f "$BASEDIR/scripts/install-plugins.sh" ]; then
  echo "Installing Claude plugins..."
  sh "$BASEDIR/scripts/install-plugins.sh"
else
  echo "Warning: install-plugins.sh not found, skipping plugin install"
fi

echo "Claude Code configuration installed."
