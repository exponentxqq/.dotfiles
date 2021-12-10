#!/bin/sh

BASEDIR=$(
  cd "$(dirname "$0")"
  pwd
)

echo start install and config in root: $BASEDIR

if [ ! -d ~/bin ]; then
    mkdir ~/bin
fi
if [ ! -d ~/.config ]; then
    mkdir ~/.config
fi

command -v curl >/dev/null 2>&1 || { sh $BASEDIR/../tool.sh curl >&2; }
command -v wget >/dev/null 2>&1 || { sh $BASEDIR/../tool.sh wget >&2; }

sh $BASEDIR/zsh/install.sh
sh $BASEDIR/asynctask/install.sh
sh $BASEDIR/tmux/install.sh
sh $BASEDIR/docker/install.sh
sh $BASEDIR/vim/install.sh


