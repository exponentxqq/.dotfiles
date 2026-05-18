#!/bin/sh

BASEDIR=$(
  cd "$(dirname "$0")"
  pwd
)

echo "start install taskit in $BASEDIR..."

# symlink global config: ~/.config/taskit/config.toml -> dotfiles/taskit/config/.tasks.toml
if [ ! -d ~/.config/taskit ]; then
  mkdir -p ~/.config/taskit
fi

if [ ! -f ~/.config/taskit/config.toml ]; then
  ln -s "$BASEDIR/config/.tasks.toml" ~/.config/taskit/config.toml
  echo "config.toml linked."
else
  echo "config.toml already exists, skip."
fi
