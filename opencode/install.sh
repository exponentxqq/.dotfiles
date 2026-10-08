#!/bin/sh

BASEDIR=$(
  cd "$(dirname "$0")"
  pwd
)

echo --------------------------------------------------------
echo ---- install opencode from "$BASEDIR" ----
echo --------------------------------------------------------

# 安装 opencode 本体（如果尚未安装）
if command -v opencode >/dev/null 2>&1; then
  echo "opencode already installed at $(command -v opencode), skipping binary installation"
else
  echo "Installing opencode binary..."
  # 优先使用系统包管理器
  TOOL_SCRIPT="$BASEDIR/../tool.sh"
  if [ -f "$TOOL_SCRIPT" ]; then
    echo "Trying system package manager via $TOOL_SCRIPT ..."
    if sh "$TOOL_SCRIPT" opencode; then
      echo "opencode installed via system package manager"
    else
      echo "System package manager failed, falling back to official curl installer..."
      curl -fsSL https://opencode.ai/install | bash
    fi
  else
    echo "tool.sh not found, falling back to official curl installer..."
    curl -fsSL https://opencode.ai/install | bash
  fi
fi

# 确保 ~/.config 目录存在
mkdir -p ~/.config

# 备份并符号链接整个 ~/.config/opencode
if [ -e ~/.config/opencode ] && [ ! -L ~/.config/opencode ]; then
  # opencode v2 的本地后台服务凭据：软链前先复制到 dotfiles，保证运行中的服务不中断。
  # service.json 已在 .gitignore 中忽略，不会进版本库；每台机器各自独立。
  if [ -f ~/.config/opencode/service.json ]; then
    cp -p ~/.config/opencode/service.json "$BASEDIR/service.json"
    echo "Preserved service.json to $BASEDIR/service.json (gitignored)"
  fi
  mv ~/.config/opencode ~/.config/opencode.bak
  echo "Backed up existing ~/.config/opencode to ~/.config/opencode.bak"
fi
ln -sfn "$BASEDIR" ~/.config/opencode
echo "Linked ~/.config/opencode -> $BASEDIR"

echo "opencode configuration installed."
echo ""
echo "Note: restart opencode to load any config changes."
