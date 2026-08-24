#!/bin/sh

a=$(uname -a)

echo "$@"
if [[ $a =~ "Darwin" ]]; then
  echo "mac"
  brew install "$@"
elif [[ $a =~ "arch" ]]; then
  echo "arch"
  # 只装缺失的包（pacman -T 认 provides，避免把 picom-git 等变体替换成官方版）
  missing=""
  for p in "$@"; do
    pacman -T "$p" >/dev/null 2>&1 || missing="$missing $p"
  done
  if [ -n "$missing" ]; then
    yay -S --noconfirm --needed $missing
  else
    echo "all packages satisfied"
  fi
else
  echo ubuntu
  sudo apt-get install -y "$@"
fi
