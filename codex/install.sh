#!/bin/sh

BASEDIR=$(
  cd "$(dirname "$0")"
  pwd
)

echo --------------------------------------------------------
echo ---- install codex config from "$BASEDIR" ----
echo --------------------------------------------------------

# 确保 ~/.codex 目录存在
mkdir -p ~/.codex

# 备份并 symlink config.toml
if [ -f ~/.codex/config.toml ] && [ ! -L ~/.codex/config.toml ]; then
  mv ~/.codex/config.toml ~/.codex/config.toml.bak
  echo "Backed up existing config.toml to config.toml.bak"
fi
ln -sf "$BASEDIR/config.toml" ~/.codex/config.toml

echo "Codex configuration installed."
echo ""
echo "Usage:"
echo "  codex --profile glm              # GLM (智谱)"
echo "  codex --profile deepseek         # DeepSeek V4 Pro"
echo "  codex -p deepseek-flash          # DeepSeek V4 Flash"
echo ""
echo "Make sure to set API keys in ~/.secrets:"
echo "  export GLM_API_KEY=\"your-key\""
echo "  export DEEPSEEK_API_KEY=\"your-key\""
