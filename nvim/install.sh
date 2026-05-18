#!/bin/sh

BASEDIR=$(
  cd "$(dirname "$0")"
  pwd
)

echo --------------------------------------------------------
echo ---- install neovim and config in "$BASEDIR"...... ----
echo --------------------------------------------------------

sh "$BASEDIR/../tool.sh" neovim

if [ -d ~/.config/nvim ]; then
  rm -rf ~/.config/nvim
fi
ln -s "$BASEDIR/nvim" ~/.config/nvim
