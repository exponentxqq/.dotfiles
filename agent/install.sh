#!/bin/sh

BASEDIR=$(
  cd "$(dirname "$0")"
  pwd
)

# ~/.agents/skills 软链由 skctl doctor 接管维护，此处不再创建
# 链接 skctl 命令到 ~/bin
mkdir -p ~/bin
ln -sfn "$BASEDIR/../tools/skctl/bin/skctl" ~/bin/skctl
